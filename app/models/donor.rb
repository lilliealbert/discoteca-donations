class Donor < ApplicationRecord
  has_many :donation_requests, dependent: :destroy
  has_many :donations, dependent: :destroy

  enum :donor_type, {
    staff: "TECA Staff",
    family: "TECA Family",
    business_nonprofit: "Business/Non-profit"
  }

  validates :name, presence: true, uniqueness: true
end
