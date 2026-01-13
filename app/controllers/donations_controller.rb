class DonationsController < ApplicationController
  before_action :authenticate_volunteer!, except: [:show]
  before_action :set_donation

  def show
    authorize @donation
  end

  def edit
    authorize @donation
  end

  def update
    authorize @donation
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
