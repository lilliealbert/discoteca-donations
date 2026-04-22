require "csv"

class EventsController < ApplicationController
  def index
    @events = Event.order(date: :asc)
  end

  def show
    @event = Event.find(params[:id])
    @unclaimed_requests = @event.donation_requests.where(volunteer_id: nil).where.not(request_status: [:yes, :no]).includes(:donor)
    @donation_requests = @event.donation_requests.where.not(volunteer_id: nil).where.not(request_status: [:yes, :no]).includes(:donor, :volunteer)
    @declined_requests = @event.donation_requests.no.includes(:donor, :volunteer)
  end

  def export_donation_requests
    @event = Event.find(params[:event_id])
    authorize @event, :show?

    donation_requests = @event.donation_requests.includes(:donor, :volunteer)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << [
        "Donor Name", "Donor Type", "Donor Email", "Donor Phone", "Donor Website",
        "Primary Contact", "Relationship to TECA",
        "Volunteer Name", "Volunteer Email",
        "Request Status", "Notes"
      ]

      donation_requests.each do |request|
        csv << [
          request.donor.name,
          request.donor.donor_type&.humanize,
          request.donor.email_address,
          request.donor.phone_number,
          request.donor.website,
          request.donor.primary_contact,
          request.donor.relationship_to_teca,
          request.volunteer&.name,
          request.volunteer&.email,
          request.request_status&.humanize,
          request.notes
        ]
      end
    end

    send_data csv_data,
              filename: "donation_requests_#{@event.name.parameterize}_#{Date.current}.csv",
              type: "text/csv"
  end

  def export_donations
    @event = Event.find(params[:event_id])
    authorize @event, :show?

    donations = @event.donations.includes(:donor, :volunteer, :donation_request)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << [
        "Donor Name", "Donor Type", "Donor Email", "Donor Phone",
        "Primary Contact", "Relationship to TECA",
        "Volunteer Name", "Volunteer Email",
        "Donation Type", "Short Description", "Quantity", "In Hand",
        "Notes", "Fine Print",
        "Request Status"
      ]

      donations.each do |donation|
        csv << [
          donation.donor.name,
          donation.donor.donor_type&.humanize,
          donation.donor.email_address,
          donation.donor.phone_number,
          donation.donor.primary_contact,
          donation.donor.relationship_to_teca,
          donation.volunteer.name,
          donation.volunteer.email,
          donation.donation_type&.humanize,
          donation.short_description,
          donation.quantity,
          donation.in_hand ? "Yes" : "No",
          donation.notes,
          donation.fine_print,
          donation.donation_request&.request_status&.humanize
        ]
      end
    end

    send_data csv_data,
              filename: "donations_#{@event.name.parameterize}_#{Date.current}.csv",
              type: "text/csv"
  end
end
