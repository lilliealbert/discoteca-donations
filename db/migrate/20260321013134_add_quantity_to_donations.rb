class AddQuantityToDonations < ActiveRecord::Migration[8.1]
  def change
    add_column :donations, :quantity, :integer
  end
end
