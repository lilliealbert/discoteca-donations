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

  enum :status, {
    draft: "draft",
    needs_review: "needs_review",
    ready_for_export: "ready_for_export"
  }

  validates :title, presence: true
  validates :category, presence: true
  validates :short_description, length: { maximum: 70 }, presence: true, if: :ready_for_export?
  validates :estimated_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :starting_bid, numericality: { greater_than_or_equal_to: 0 }, presence: true, if: :ready_for_export?
end
