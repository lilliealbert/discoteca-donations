class AddDonationRequestToDonations < ActiveRecord::Migration[8.1]
  def change
    add_reference :donations, :donation_request, foreign_key: true
  end
end
