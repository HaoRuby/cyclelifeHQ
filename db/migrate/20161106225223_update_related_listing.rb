class UpdateRelatedListing < ActiveRecord::Migration
  def change
    exec_update(
     "ALTER TABLE related_listings
       CHANGE
         action heading VARCHAR(255)",
      "Add heading to related_listing",
    [])
  end
end
