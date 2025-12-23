class AddNameToVolunteers < ActiveRecord::Migration[8.1]
  def change
    add_column :volunteers, :name, :string
  end
end
