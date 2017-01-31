class AddRelatedOrder < ActiveRecord::Migration
  def change
    exec_update(
     "ALTER TABLE related_listings
       ADD related_order INT(2)",
      "Add order to listings",
    [])
  end
end
