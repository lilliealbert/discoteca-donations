class AddPrimaryContactToDonors < ActiveRecord::Migration[8.1]
  def change
    add_column :donors, :primary_contact, :string
  end
end
