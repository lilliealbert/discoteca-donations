# frozen_string_literal: true

class DonationPolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    return true if admin?
    return false unless volunteer

    # Volunteers can edit donations they own
    record.volunteer_id == volunteer.id
  end
end
