class AddRelatedIdsListings < ActiveRecord::Migration
  def change
    exec_update(
     "ALTER TABLE listings
       ADD related_ids INT(5)",
      "Add related_ids to listings",
    [])
  end
end
