class ChangeRelatedListingListings < ActiveRecord::Migration
  def change
    exec_update(
     "ALTER TABLE listings
       CHANGE
         related_listings_id related_listing VARCHAR(255)",
      "Change related_listing in listings",
    [])
  end
end
