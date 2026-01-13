class Event < ApplicationRecord
  has_many :donation_requests, dependent: :destroy
  has_many :donations, dependent: :destroy

  CURRENT_AUCTION_NAME = "DiscoTECA 2026"
  scope :default_event, -> { where(name: CURRENT_AUCTION_NAME) }
end
