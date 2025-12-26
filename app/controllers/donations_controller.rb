class DonationsController < ApplicationController
  before_action :set_donation

  def show
  end

  def edit
  end

  def update
    if @donation.update(donation_params)
      redirect_to @donation, notice: "Donation updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_donation
    @donation = Donation.find(params[:id])
  end

  def donation_params
    params.require(:donation).permit(:donation_type, :in_hand, :short_description, :notes, :fine_print)
  end
end
