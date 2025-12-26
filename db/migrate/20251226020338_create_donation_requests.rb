class CreateDonationRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :donation_requests do |t|
      t.references :donor, null: false, foreign_key: true
      t.references :volunteer, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :request_status
      t.text :notes

      t.timestamps
    end
  end
end
