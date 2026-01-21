# frozen_string_literal: true

class DonationRequestPolicy < ApplicationPolicy
  def show?
    true
  end

  def new?
    volunteer.present?
  end

  def create?
    volunteer.present?
  end

  def update?
    return true if admin?
    return false unless volunteer

    # Volunteers can claim unclaimed requests
    return true if record.volunteer_id.nil?

    # Volunteers can edit requests they have claimed
    record.volunteer_id == volunteer.id
  end

  def claim?
    return true if admin?
    return false unless volunteer

    # Can only claim unclaimed requests
    record.volunteer_id.nil?
  end

  def offered?
    admin?
  end
end