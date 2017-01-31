class AddDefaultsToLinks < ActiveRecord::Migration
  def up
    exec_update(
      "ALTER TABLE listing_shapes
       CHANGE 
         deeplink_enabled deeplink_enabled tinyint(1) DEFAULT 0,
       CHANGE 
         related_enabled related_enabled tinyint(1) DEFAULT 0",  
      "Add defaults to deeplink_enabled and related_enabled in listing_shapes",
      [])
  end
end
