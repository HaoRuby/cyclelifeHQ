class AddRelatedToListings < ActiveRecord::Migration
  def change
    exec_update(
      "ALTER TABLE listings
       ADD
         related_listings_id int(5)",
      "Added related listing to listings",
      [])
  end
end
