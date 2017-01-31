#lib/tasks/related_listings.rake
namespace :related do
	desc 'Regenerate related listings'
	task  recalculate: :environment do
		RelatedListing.all.each do |rlisting|
			#get the new listings
	    distance=30 #in km
	    latitude = Location.where('listing_id' => rlisting.listing_id).all[0].latitude
      longitude = Location.where('listing_id' => rlisting.listing_id).all[0].longitude
	    close_listings = Location.get_coords(latitude,longitude,distance)#.limit(4)
	    related_count = 0
	    related_list = []
	    close_listings.each do | close |
	      if (close.listing_id.blank? || close.listing_id == rlisting.listing_id)
	        next
	      end
	      the_listing = Listing.find(close.listing_id)
	      if (the_listing.category_id.to_s == rlisting.category.to_s && the_listing.listing_shape_id.to_s == rlisting.shape.to_s)
	        if (the_listing.closed?)
	          next
	        end
	        if (related_count >= 3)
	          break
	        else
	          related_count += 1
	        end
	        related_list.push(close.listing_id)
	      end
	    end
	    rl=related_list.join(" ")
	    rlisting.update_attribute(:related_listing_ids, rl)
	  end
	end
end