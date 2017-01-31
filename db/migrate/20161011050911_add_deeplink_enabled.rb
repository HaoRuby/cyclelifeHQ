class AddDeeplinkEnabled < ActiveRecord::Migration
  def change
    exec_update(
      "ALTER TABLE listing_shapes
       ADD
         deeplink_enabled TINYINT(1) NOT NULL",
      "Added columns for deep links",
      [])
  end
end
