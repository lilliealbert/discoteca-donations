class Donation < ApplicationRecord
  belongs_to :donor
  belongs_to :volunteer
  belongs_to :event
  belongs_to :donation_request, optional: true

  enum :donation_type, {
    digital: "digital",
    physical: "physical",
    other: "other"
  }
end
