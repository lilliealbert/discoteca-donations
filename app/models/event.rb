class Event < ApplicationRecord
  has_many :donation_requests, dependent: :destroy
  has_many :donations, dependent: :destroy
end
