class AuctionListingsController < ApplicationController
  before_action :set_donation
  before_action :set_auction_listing, only: [:edit, :update, :destroy]

  def new
    authorize @donation, :manage_auction_listing?
    @auction_listing = @donation.build_auction_listing
  end

  def create
    authorize @donation, :manage_auction_listing?
    @auction_listing = @donation.build_auction_listing(auction_listing_params)

    if @auction_listing.save
      redirect_to @donation, notice: "Auction listing created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @donation, :manage_auction_listing?
  end

  def update
    authorize @donation, :manage_auction_listing?

    if @auction_listing.update(auction_listing_params)
      redirect_to @donation, notice: "Auction listing updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @donation, :manage_auction_listing?
    @auction_listing.destroy
    redirect_to @donation, notice: "Auction listing deleted."
  end

  private

  def set_donation
    @donation = Donation.find(params[:donation_id])
  end

  def set_auction_listing
    @auction_listing = @donation.auction_listing
  end

  def auction_listing_params
    params.require(:auction_listing).permit(:title, :short_description, :long_description, :category, :estimated_value, :starting_bid)
  end
end
