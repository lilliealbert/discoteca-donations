# frozen_string_literal: true

class DonorPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def update?
    return true if admin?
    return false unless volunteer

    # Volunteers can edit donors associated with their claimed requests
    record.donation_requests.exists?(volunteer_id: volunteer.id)
  end
end