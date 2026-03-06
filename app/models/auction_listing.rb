class AuctionListing < ApplicationRecord
  belongs_to :donation

  enum :category, {
    experiences: "experiences",
    camps: "camps",
    museums: "museums",
    staff_offering: "staff_offering",
    other: "other",
    sports: "sports",
    shopping: "shopping",
    parent_offering: "parent_offering",
    food: "food",
    dessert: "dessert",
    wellness: "wellness",
    live_auction: "live_auction"
  }

  validates :title, presence: true
  validates :category, presence: true
  validates :short_description, length: { maximum: 70 }
  validates :estimated_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :starting_bid, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
