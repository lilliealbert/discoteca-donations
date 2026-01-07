class DonationRequestsController < ApplicationController
  before_action :set_donation_request

  def show
  end

  def edit
  end

  def update
    if @donation_request.update(donation_request_params)
      redirect_to @donation_request, notice: "Donation request updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_donation_request
    @donation_request = DonationRequest.find(params[:id])
  end

  def donation_request_params
    params.require(:donation_request).permit(:request_status, :notes, :volunteer_id)
  end
end
