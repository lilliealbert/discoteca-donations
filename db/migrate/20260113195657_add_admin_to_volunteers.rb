class AddAdminToVolunteers < ActiveRecord::Migration[8.1]
  def change
    add_column :volunteers, :admin, :boolean, default: false, null: false
  end
end
