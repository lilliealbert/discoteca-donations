class DonorsController < ApplicationController
  before_action :authenticate_volunteer!, except: [:index, :show]
  before_action :set_donor, only: [:show, :edit, :update]

  def index
    @donors = Donor.order(name: :asc)
  end

  def show
    @donation_requests = @donor.donation_requests.includes(:event, :volunteer)
  end

  def edit
    authorize @donor
  end

  def update
    authorize @donor
    if @donor.update(donor_params)
      redirect_to @donor, notice: "Donor updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_donor
    @donor = Donor.find(params[:id])
  end

  def donor_params
    params.require(:donor).permit(:name, :donor_type, :email_address, :phone_number, :website, :primary_contact, :relationship_to_teca, :notes)
  end
end
