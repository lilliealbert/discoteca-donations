class EventsController < ApplicationController
  def index
    @events = Event.order(date: :asc)
  end

  def show
    @event = Event.find(params[:id])
    @donation_requests = @event.donation_requests.includes(:donor, :volunteer)
    @donations = @event.donations.includes(:donor, :volunteer)
  end
end
