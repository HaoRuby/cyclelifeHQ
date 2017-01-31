class AddListingIdRelated < ActiveRecord::Migration
  def change
    exec_update(
     "ALTER TABLE related_listings
       ADD listing_id INT(5),
       CHANGE
         listing_ids related_listing_ids VARCHAR(255)",
      "Changes to ids for related_listing",
    [])

  end
end
