class AddStatusToAuctionListings < ActiveRecord::Migration[8.1]
  def change
    add_column :auction_listings, :status, :string, default: "draft", null: false
  end
end
