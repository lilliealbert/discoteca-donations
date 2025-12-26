class DonorsController < ApplicationController
  def index
    @donors = Donor.order(name: :asc)
  end

  def show
    @donor = Donor.find(params[:id])
    @donation_requests = @donor.donation_requests.includes(:event, :volunteer)
  end
end
