class EventsController < ApplicationController
  def index
    @events = Event.order(date: :asc)
  end

  def show
    @event = Event.find(params[:id])
    @unclaimed_requests = @event.donation_requests.where(volunteer_id: nil).where.not(request_status: [:yes, :no]).includes(:donor)
    @donation_requests = @event.donation_requests.where.not(volunteer_id: nil).where.not(request_status: [:yes, :no]).includes(:donor, :volunteer)
    @donations = @event.donations.includes(:donor, :volunteer)
    @declined_requests = @event.donation_requests.no.includes(:donor, :volunteer)
  end
end
