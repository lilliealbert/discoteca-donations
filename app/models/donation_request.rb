class DonationRequest < ApplicationRecord
  belongs_to :donor
  belongs_to :volunteer
  belongs_to :event

  enum :request_status, {
    unasked: "unasked",
    asked_once: "asked_once",
    asked_twice: "asked_twice",
    asked_thrice: "asked_thrice",
    no: "no",
    yes: "yes"
  }
end
