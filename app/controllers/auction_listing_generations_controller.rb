class AuctionListingGenerationsController < ApplicationController
  def create
    @donation = Donation.find(params[:donation_id])
    authorize @donation, :manage_auction_listing?

    result = ListingGenerator.new(@donation).generate

    if result.success
      render json: result.data
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end
end
