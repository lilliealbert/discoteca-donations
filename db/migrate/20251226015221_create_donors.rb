class CreateDonors < ActiveRecord::Migration[8.1]
  def change
    create_table :donors do |t|
      t.string :name
      t.string :email_address
      t.string :phone_number
      t.string :website
      t.text :notes
      t.string :relationship_to_teca

      t.timestamps
    end
  end
end
