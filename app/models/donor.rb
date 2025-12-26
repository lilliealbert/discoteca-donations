class Donor < ApplicationRecord
  has_many :donation_requests, dependent: :destroy
end
