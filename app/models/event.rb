class Event < ApplicationRecord
  has_many :donation_requests, dependent: :destroy
end
