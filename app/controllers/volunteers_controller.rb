class VolunteersController < ApplicationController
  before_action :authenticate_volunteer!, only: [:dashboard]

  def index
    @volunteers = Volunteer.order(name: :asc, email: :asc)
  end

  def show
    @volunteer = Volunteer.find(params[:id])
    @donation_requests = @volunteer.donation_requests.includes(:donor, :event)
    @donations = @volunteer.donations.includes(:donor, :event)
  end

  def dashboard
    @volunteer = current_volunteer
    @open_donation_requests = @volunteer.donation_requests.joins(:event).open.where(events: {name: Event::CURRENT_AUCTION_NAME}).includes(:donor, :event)
    @donations = @volunteer.donations.joins(:event).where(events: {name: Event::CURRENT_AUCTION_NAME}).includes(:donor, :event)
  end
end