require 'rails_helper'

RSpec.describe "AuctionListings", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:volunteer) { Volunteer.create!(email: "volunteer@example.com", password: "password123", name: "Test Volunteer") }
  let(:admin) { Volunteer.create!(email: "admin@example.com", password: "password123", name: "Admin", admin: true) }
  let(:event) { Event.create!(name: Event::CURRENT_AUCTION_NAME, date: Date.tomorrow) }
  let(:donor) { Donor.create!(name: "Generous Giraffe") }
  let(:donation) do
    Donation.create!(
      donor: donor,
      event: event,
      volunteer: volunteer,
      donation_type: :physical,
      short_description: "A nice item"
    )
  end

  describe "GET /donations/:donation_id/auction_listing/new" do
    context "as an admin" do
      before { sign_in admin, scope: :volunteer }

      it "displays the new auction listing form" do
        get new_donation_auction_listing_path(donation)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("New Auction Listing")
      end
    end

    context "as a non-admin" do
      before { sign_in volunteer, scope: :volunteer }

      it "denies access" do
        get new_donation_auction_listing_path(donation)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  describe "POST /donations/:donation_id/auction_listing" do
    let(:valid_params) do
      {
        auction_listing: {
          title: "Amazing Experience",
          category: "experiences",
          short_description: "A brief description",
          long_description: "A longer description with more details",
          estimated_value: 100.00,
          starting_bid: 50.00
        }
      }
    end

    context "as an admin" do
      before { sign_in admin, scope: :volunteer }

      it "creates an auction listing" do
        expect {
          post donation_auction_listing_path(donation), params: valid_params
        }.to change(AuctionListing, :count).by(1)

        expect(response).to redirect_to(donation_path(donation))
        follow_redirect!
        expect(response.body).to include("Auction listing created successfully")

        listing = AuctionListing.last
        expect(listing.title).to eq("Amazing Experience")
        expect(listing.category).to eq("experiences")
        expect(listing.estimated_value).to eq(100.00)
        expect(listing.starting_bid).to eq(50.00)
        expect(listing.donation).to eq(donation)
      end

      it "returns error when title is missing" do
        invalid_params = valid_params.deep_dup
        invalid_params[:auction_listing][:title] = ""

        expect {
          post donation_auction_listing_path(donation), params: invalid_params
        }.not_to change(AuctionListing, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error when category is missing" do
        invalid_params = valid_params.deep_dup
        invalid_params[:auction_listing][:category] = ""

        expect {
          post donation_auction_listing_path(donation), params: invalid_params
        }.not_to change(AuctionListing, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "as a non-admin" do
      before { sign_in volunteer, scope: :volunteer }

      it "denies access" do
        expect {
          post donation_auction_listing_path(donation), params: valid_params
        }.not_to change(AuctionListing, :count)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  describe "GET /donations/:donation_id/auction_listing/edit" do
    let!(:auction_listing) do
      AuctionListing.create!(
        donation: donation,
        title: "Existing Listing",
        category: "sports"
      )
    end

    context "as an admin" do
      before { sign_in admin, scope: :volunteer }

      it "displays the edit form" do
        get edit_donation_auction_listing_path(donation)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Edit Auction Listing")
        expect(response.body).to include("Existing Listing")
      end
    end

    context "as a non-admin" do
      before { sign_in volunteer, scope: :volunteer }

      it "denies access" do
        get edit_donation_auction_listing_path(donation)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end

  describe "PATCH /donations/:donation_id/auction_listing" do
    let!(:auction_listing) do
      AuctionListing.create!(
        donation: donation,
        title: "Original Title",
        category: "sports",
        estimated_value: 50.00
      )
    end

    context "as an admin" do
      before { sign_in admin, scope: :volunteer }

      it "updates the auction listing" do
        patch donation_auction_listing_path(donation), params: {
          auction_listing: {
            title: "Updated Title",
            estimated_value: 150.00
          }
        }

        expect(response).to redirect_to(donation_path(donation))
        follow_redirect!
        expect(response.body).to include("Auction listing updated successfully")

        auction_listing.reload
        expect(auction_listing.title).to eq("Updated Title")
        expect(auction_listing.estimated_value).to eq(150.00)
      end

      it "returns error for invalid update" do
        patch donation_auction_listing_path(donation), params: {
          auction_listing: { title: "" }
        }

        expect(response).to have_http_status(:unprocessable_content)

        auction_listing.reload
        expect(auction_listing.title).to eq("Original Title")
      end
    end

    context "as a non-admin" do
      before { sign_in volunteer, scope: :volunteer }

      it "denies access" do
        patch donation_auction_listing_path(donation), params: {
          auction_listing: { title: "Hacked Title" }
        }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")

        auction_listing.reload
        expect(auction_listing.title).to eq("Original Title")
      end
    end
  end

  describe "DELETE /donations/:donation_id/auction_listing" do
    let!(:auction_listing) do
      AuctionListing.create!(
        donation: donation,
        title: "To Be Deleted",
        category: "other"
      )
    end

    context "as an admin" do
      before { sign_in admin, scope: :volunteer }

      it "deletes the auction listing" do
        expect {
          delete donation_auction_listing_path(donation)
        }.to change(AuctionListing, :count).by(-1)

        expect(response).to redirect_to(donation_path(donation))
        follow_redirect!
        expect(response.body).to include("Auction listing deleted")
      end
    end

    context "as a non-admin" do
      before { sign_in volunteer, scope: :volunteer }

      it "denies access" do
        expect {
          delete donation_auction_listing_path(donation)
        }.not_to change(AuctionListing, :count)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end
  end
end
