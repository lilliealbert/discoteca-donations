class DonationRequestsController < ApplicationController
  before_action :set_donation_request

  def show
  end

  def edit
  end

  def update
    was_unclaimed = @donation_request.volunteer_id.nil?

    if @donation_request.update(donation_request_params)
      respond_to do |format|
        format.html do
          if was_unclaimed && @donation_request.volunteer_id.present?
            redirect_to event_path(@donation_request.event), notice: "#{@donation_request.donor.name} claimed successfully."
          else
            redirect_to @donation_request, notice: "Donation request updated successfully."
          end
        end
        format.json { render json: { status: @donation_request.request_status } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @donation_request.errors }, status: :unprocessable_entity }
      end
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
