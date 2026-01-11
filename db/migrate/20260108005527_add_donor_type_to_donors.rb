class AddDonorTypeToDonors < ActiveRecord::Migration[8.1]
  def change
    add_column :donors, :donor_type, :string
  end
end
