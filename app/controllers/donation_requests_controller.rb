class DonationRequestsController < ApplicationController
  before_action :authenticate_volunteer!, except: [:show]
  before_action :set_donation_request, only: [:show, :edit, :update]

  def show
    authorize @donation_request
  end

  def new
    @donation_request = DonationRequest.new
    authorize @donation_request
    @donors = Donor.order(:name)
    @events = Event.order(date: :desc)
    @selected_event_id = params[:event_id]
  end

  def create
    @donation_request = DonationRequest.new(donation_request_params)
    authorize @donation_request

    # Handle new donor creation
    if params[:create_new_donor] == "1" && params[:new_donor].present?
      donor = Donor.new(new_donor_params)
      if donor.save
        @donation_request.donor = donor
      else
        @donors = Donor.order(:name)
        @events = Event.order(date: :desc)
        @donation_request.errors.add(:base, "Could not create donor: #{donor.errors.full_messages.join(', ')}")
        return render :new, status: :unprocessable_entity
      end
    end

    # volunteer_id comes from params if set, otherwise nil (unassigned)
    @donation_request.request_status = :unasked if @donation_request.request_status.blank?

    if @donation_request.save
      redirect_to @donation_request, notice: "Donation request created successfully."
    else
      @donors = Donor.order(:name)
      @events = Event.order(date: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @donation_request
  end

  def update
    authorize @donation_request
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
    params.require(:donation_request).permit(:request_status, :notes, :volunteer_id, :donor_id, :event_id)
  end

  def new_donor_params
    params.require(:new_donor).permit(:name, :donor_type, :email_address, :phone_number, :website, :primary_contact, :relationship_to_teca, :notes)
  end
end
