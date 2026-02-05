require 'rails_helper'

RSpec.describe "DonationRequests", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:volunteer) { Volunteer.create!(email: "volunteer@example.com", password: "password123", name: "Test Volunteer") }
  let(:event) { Event.create!(name: Event::CURRENT_AUCTION_NAME, date: Date.tomorrow) }

  before do
    sign_in volunteer, scope: :volunteer
  end

  describe "POST /donation_requests" do
    context "when creating a new donor" do
      let(:valid_params) do
        {
          create_new_donor: "1",
          new_donor: {
            name: "Fuzzy Penguin Inc",
            donor_type: "business_nonprofit",
            email_address: "fuzzy@penguin.com",
            phone_number: "415-555-1234",
            website: "https://fuzzypenguin.com",
            primary_contact: "Percy Penguin",
            relationship_to_teca: "Local business",
            notes: "Loves fish"
          },
          donation_request: {
            event_id: event.id,
            notes: "Potential silent auction item"
          }
        }
      end

      it "creates both a donor and a donation request" do
        expect {
          post donation_requests_path, params: valid_params
        }.to change(Donor, :count).by(1)
         .and change(DonationRequest, :count).by(1)

        expect(response).to redirect_to(donation_request_path(DonationRequest.last))
        follow_redirect!
        expect(response.body).to include("Donation request created successfully")

        donor = Donor.last
        expect(donor.name).to eq("Fuzzy Penguin Inc")
        expect(donor.email_address).to eq("fuzzy@penguin.com")
        expect(donor.donor_type).to eq("business_nonprofit")
        expect(donor.primary_contact).to eq("Percy Penguin")

        donation_request = DonationRequest.last
        expect(donation_request.donor).to eq(donor)
        expect(donation_request.event).to eq(event)
        expect(donation_request.notes).to eq("Potential silent auction item")
        expect(donation_request.request_status).to eq("unasked")
      end

      it "returns error when donor name is missing" do
        invalid_params = valid_params.deep_dup
        invalid_params[:new_donor][:name] = ""

        expect {
          post donation_requests_path, params: invalid_params
        }.to change(Donor, :count).by(0)
         .and change(DonationRequest, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error when donor name already exists" do
        Donor.create!(name: "Fuzzy Penguin Inc")

        expect {
          post donation_requests_path, params: valid_params
        }.to change(Donor, :count).by(0)
         .and change(DonationRequest, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when using an existing donor" do
      let(:existing_donor) { Donor.create!(name: "Gentle Giraffe Gallery", donor_type: "business_nonprofit") }

      let(:valid_params) do
        {
          donation_request: {
            donor_id: existing_donor.id,
            event_id: event.id,
            notes: "Annual donation"
          }
        }
      end

      it "creates a donation request without creating a new donor" do
        existing_donor # ensure donor exists before counting

        expect {
          post donation_requests_path, params: valid_params
        }.to change(Donor, :count).by(0)
         .and change(DonationRequest, :count).by(1)

        expect(response).to redirect_to(donation_request_path(DonationRequest.last))
        follow_redirect!
        expect(response.body).to include("Donation request created successfully")

        donation_request = DonationRequest.last
        expect(donation_request.donor).to eq(existing_donor)
        expect(donation_request.event).to eq(event)
        expect(donation_request.notes).to eq("Annual donation")
        expect(donation_request.request_status).to eq("unasked")
      end
    end
  end

  describe "PATCH /donation_requests/:id" do
    let(:donor) { Donor.create!(name: "Curious Capybara Cafe") }
    let(:donation_request) { DonationRequest.create!(donor: donor, event: event, request_status: :unasked) }

    it "updates the status and notes" do
      donation_request.update!(volunteer: volunteer)

      patch donation_request_path(donation_request), params: {
        donation_request: {
          request_status: "asked_once",
          notes: "Left voicemail"
        }
      }

      expect(response).to redirect_to(donation_request_path(donation_request))
      follow_redirect!
      expect(response.body).to include("Donation request updated successfully")

      donation_request.reload
      expect(donation_request.request_status).to eq("asked_once")
      expect(donation_request.notes).to eq("Left voicemail")
    end

    it "claims an unclaimed request and redirects to event page" do
      patch donation_request_path(donation_request), params: {
        donation_request: {
          volunteer_id: volunteer.id
        }
      }

      expect(response).to redirect_to(event_path(event))
      follow_redirect!
      expect(response.body).to include("claimed successfully")

      donation_request.reload
      expect(donation_request.volunteer).to eq(volunteer)
    end

    it "creates a donation when status changes to yes" do
      donation_request.update!(volunteer: volunteer, request_status: :asked_once)

      patch donation_request_path(donation_request), params: {
        donation_request: { request_status: "yes" }
      }

      expect(response).to redirect_to(edit_donation_path(Donation.last))

      donation = Donation.last
      expect(donation.donor).to eq(donor)
      expect(donation.event).to eq(event)
      expect(donation.volunteer).to eq(volunteer)
      expect(donation.donation_request).to eq(donation_request)
    end

    context "with JSON format" do
      it "returns the updated status as JSON" do
        donation_request.update!(volunteer: volunteer)

        patch donation_request_path(donation_request, format: :json), params: {
          donation_request: { request_status: "asked_once" }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("asked_once")
      end

      it "returns redirect_to when status changes to yes" do
        donation_request.update!(volunteer: volunteer, request_status: :asked_once)

        patch donation_request_path(donation_request, format: :json), params: {
          donation_request: { request_status: "yes" }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("yes")
        expect(json["redirect_to"]).to include("/donations/")
      end
    end

    context "authorization" do
      it "prevents editing a request claimed by another volunteer" do
        other_volunteer = Volunteer.create!(email: "other@example.com", password: "password123", name: "Other Volunteer")
        donation_request.update!(volunteer: other_volunteer, request_status: :asked_once)

        patch donation_request_path(donation_request), params: {
          donation_request: { request_status: "asked_twice" }
        }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  describe "GET /donation_requests/offered" do
    let(:donor) { Donor.create!(name: "Optimistic Otter") }

    before do
      DonationRequest.create!(donor: donor, event: event, request_status: :offered, notes: "Free swimming lessons")
    end

    context "as an admin" do
      let(:admin) { Volunteer.create!(email: "admin@example.com", password: "password123", name: "Admin", admin: true) }

      before { sign_in admin, scope: :volunteer }

      it "displays offered donation requests" do
        get offered_donation_requests_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Optimistic Otter")
        expect(response.body).to include("Free swimming lessons")
      end
    end

    context "as a non-admin" do
      it "denies access" do
        get offered_donation_requests_path

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end
end
