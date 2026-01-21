class DonationRequest < ApplicationRecord
  belongs_to :donor
  belongs_to :volunteer, optional: true
  belongs_to :event
  has_one :donation

  after_save :create_donation, if: :became_accepted?

  enum :request_status, {
    unasked: "unasked",
    asked_once: "asked_once",
    asked_twice: "asked_twice",
    asked_thrice: "asked_thrice",
    no: "no",
    yes: "yes",
    offered: "offered"
  }

  scope :open, -> { where.not(request_status: %w[yes no]) }

  validates :volunteer, presence: true, unless: -> { unasked? || offered? }
  validates :notes, presence: true, if: :offered?

  private

  def became_accepted?
    saved_change_to_request_status? && yes?
  end

  def create_donation
    Donation.create!(
      donation_request: self,
      donor: donor,
      volunteer: volunteer,
      event: event,
      in_hand: false
    )
  end
end
