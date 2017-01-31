class RelatedListings < ActiveRecord::Migration
  def change
    create_table :related_listings do |t|
      t.string :category
      t.string :subcategory
      t.string :shape
      t.string :listing_ids
      t.string :action
      t.timestamps :created_at, :datetime
    end
  end
end
