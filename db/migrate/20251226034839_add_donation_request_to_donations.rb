class AddDonationRequestToDonations < ActiveRecord::Migration[8.1]
  def change
    add_reference :donations, :donation_request, null: false, foreign_key: true
  end
end
