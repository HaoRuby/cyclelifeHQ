# == Schema Information
#
# Table name: related_listings
#
#  id                  :integer          not null, primary key
#  category            :string(255)
#  subcategory         :string(255)
#  shape               :string(255)
#  related_listing_ids :string(255)
#  heading             :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  listing_id          :integer
#  related_order       :integer
#

class RelatedListing < ActiveRecord::Base


  def new
  	@name
  	@category
  	@subcategory
  	@shape
  	@listing_ids
  	@action
  	@related_listing_ids
  end

end

