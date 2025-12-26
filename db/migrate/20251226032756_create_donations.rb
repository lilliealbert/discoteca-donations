class CreateDonations < ActiveRecord::Migration[8.1]
  def change
    create_table :donations do |t|
      t.references :donor, null: false, foreign_key: true
      t.references :volunteer, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :donation_type
      t.boolean :in_hand
      t.text :short_description
      t.text :notes
      t.text :fine_print

      t.timestamps
    end
  end
end
