class ChangeVolunteerNullableOnDonationRequests < ActiveRecord::Migration[8.1]
  def change
    change_column_null :donation_requests, :volunteer_id, true
  end
end
