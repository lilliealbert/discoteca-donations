require 'rails_helper'

RSpec.describe "AuctionListingGenerations", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:volunteer) { Volunteer.create!(email: "amethyst@crystalgems.com", password: "password123", name: "Amethyst") }
  let(:admin) { Volunteer.create!(email: "garnet@crystalgems.com", password: "password123", name: "Garnet", admin: true) }
  let(:event) { Event.create!(name: Event::CURRENT_AUCTION_NAME, date: Date.tomorrow) }
  let(:donor) { Donor.create!(name: "Greg Universe") }
  let(:donation) do
    Donation.create!(
      donor: donor,
      event: event,
      volunteer: volunteer,
      donation_type: :physical,
      short_description: "Guitar lessons from Mr. Universe",
      notes: "Learn to play like a rock star! 4 one-hour sessions included.",
      fine_print: "Must be scheduled within 6 months."
    )
  end

  let(:successful_result) do
    ListingGenerator::Result.new(
      success: true,
      data: {
        "title" => "Rock Star Guitar Lessons with Greg Universe",
        "short_description" => "Learn guitar from Beach City's legendary musician!",
        "long_description" => "Get four one-hour guitar lessons from Greg Universe himself. Whether you're a beginner or looking to improve your skills, Greg's patient teaching style will have you strumming in no time."
      }
    )
  end

  let(:error_result) do
    ListingGenerator::Result.new(
      success: false,
      error: "API rate limit exceeded"
    )
  end

  describe "POST /donations/:donation_id/auction_listing_generation" do
    context "as an admin" do
      before { sign_in admin, scope: :volunteer }

      it "returns generated content as JSON" do
        allow_any_instance_of(ListingGenerator).to receive(:generate).and_return(successful_result)

        post donation_auction_listing_generation_path(donation),
             headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")

        json = JSON.parse(response.body)
        expect(json["title"]).to eq("Rock Star Guitar Lessons with Greg Universe")
        expect(json["short_description"]).to eq("Learn guitar from Beach City's legendary musician!")
        expect(json["long_description"]).to include("four one-hour guitar lessons")
      end

      it "returns error JSON when generation fails" do
        allow_any_instance_of(ListingGenerator).to receive(:generate).and_return(error_result)

        post donation_auction_listing_generation_path(donation),
             headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("API rate limit exceeded")
      end
    end

    context "as a non-admin volunteer" do
      before { sign_in volunteer, scope: :volunteer }

      it "denies access" do
        post donation_auction_listing_generation_path(donation),
             headers: { "Accept" => "application/json" }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "as an unauthenticated user" do
      it "returns unauthorized for JSON requests" do
        post donation_auction_listing_generation_path(donation),
             headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:unauthorized)
      end

      it "redirects to sign in for HTML requests" do
        post donation_auction_listing_generation_path(donation)

        expect(response).to redirect_to(new_volunteer_session_path)
      end
    end
  end
end
