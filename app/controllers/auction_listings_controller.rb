require "csv"

class AuctionListingsController < ApplicationController
  before_action :set_donation, except: [:export]
  before_action :set_auction_listing, only: [:edit, :update, :destroy]

  def export
    @event = Event.find(params[:event_id])
    authorize Donation, :index?

    listings = AuctionListing.joins(:donation)
                             .where(donations: { event_id: @event.id })
                             .where(status: :ready_for_export)
                             .includes(:donation)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["title", "display section", "estimated value", "starting bid", "short description", "long description"]

      listings.find_each do |listing|
        csv << [
          listing.title,
          listing.category,
          listing.estimated_value,
          listing.starting_bid,
          listing.short_description,
          listing.long_description
        ]
      end
    end

    send_data csv_data,
              filename: "auction_listings_#{@event.name.parameterize}_#{Date.current}.csv",
              type: "text/csv"
  end

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
      render :new, status: :unprocessable_content
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
      render :edit, status: :unprocessable_content
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
    params.require(:auction_listing).permit(:title, :short_description, :long_description, :category, :status, :estimated_value, :starting_bid)
  end
end
