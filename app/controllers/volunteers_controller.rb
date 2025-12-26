class VolunteersController < ApplicationController
  def index
    @volunteers = Volunteer.order(name: :asc, email: :asc)
  end

  def show
    @volunteer = Volunteer.find(params[:id])
    @donation_requests = @volunteer.donation_requests.includes(:donor, :event)
    @donations = @volunteer.donations.includes(:donor, :event)
  end
end