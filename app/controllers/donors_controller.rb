class DonorsController < ApplicationController
  def index
    @donors = Donor.order(name: :asc)
  end

  def show
    @donor = Donor.find(params[:id])
  end
end
