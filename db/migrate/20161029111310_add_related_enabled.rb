class AddRelatedEnabled < ActiveRecord::Migration
  def change
    exec_update(
      "ALTER TABLE listing_shapes
       ADD
         related_enabled TINYINT(1) NOT NULL",
      "Added columns for related listings",
      [])
  end
end
