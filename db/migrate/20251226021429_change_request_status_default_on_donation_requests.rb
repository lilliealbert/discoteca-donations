class ChangeRequestStatusDefaultOnDonationRequests < ActiveRecord::Migration[8.1]
  def change
    change_column_default :donation_requests, :request_status, from: nil, to: "unasked"
  end
end
