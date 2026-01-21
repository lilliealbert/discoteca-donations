class PublicOffersController < ApplicationController
  skip_before_action :authenticate_volunteer!
  layout "public"

  def new
    @donor = Donor.new
    @donation_request = DonationRequest.new
  end

  def create
    @donor = Donor.new(donor_params)
    @donation_request = DonationRequest.new(donation_request_params)

    ActiveRecord::Base.transaction do
      if @donor.save
        @donation_request.donor = @donor
        @donation_request.event = Event.default_event.first
        @donation_request.request_status = :offered

        if @donation_request.save
          redirect_to thank_you_public_offers_path, notice: "Thank you for your donation offer!"
        else
          raise ActiveRecord::Rollback
        end
      end
    end

    unless performed?
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you
  end

  private

  def donor_params
    params.require(:donor).permit(:name, :donor_type, :email_address, :phone_number, :website, :primary_contact, :relationship_to_teca, :notes)
  end

  def donation_request_params
    params.require(:donation_request).permit(:notes)
  end
end