class Donation < ApplicationRecord
  belongs_to :donor
  belongs_to :volunteer
  belongs_to :event

  enum :donation_type, {
    digital: "digital",
    physical: "physical",
    other: "other"
  }
end
