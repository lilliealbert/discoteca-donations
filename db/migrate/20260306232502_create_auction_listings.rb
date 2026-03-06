class CreateAuctionListings < ActiveRecord::Migration[8.1]
  def change
    create_table :auction_listings do |t|
      t.references :donation, null: false, foreign_key: true
      t.string :title
      t.text :short_description
      t.text :long_description
      t.string :category
      t.decimal :estimated_value, precision: 10, scale: 2
      t.decimal :starting_bid, precision: 10, scale: 2

      t.timestamps
    end
  end
end
