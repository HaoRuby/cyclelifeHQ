# == Schema Information
#
# Table name: locations
#
#  id             :integer          not null, primary key
#  latitude       :float(24)
#  longitude      :float(24)
#  address        :string(255)
#  google_address :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  listing_id     :integer
#  person_id      :string(255)
#  location_type  :string(255)
#  community_id   :integer
#
# Indexes
#
#  index_locations_on_community_id            (community_id)
#  index_locations_on_latitude_and_longitude  (latitude,longitude)
#  index_locations_on_listing_id              (listing_id)
#  index_locations_on_person_id               (person_id)
#

#CLHQ
class Location < ActiveRecord::Base

  belongs_to :person
  belongs_to :listing
  belongs_to :community
  #CLHQ
  alias_attribute :lat, :latitude
  alias_attribute :lon, :latitude
  geocoded_by :address
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }
  reverse_geocoded_by :latitude, :longitude, :address => :address
  after_validation :reverse_geocode, unless: ->(obj) { obj.address.present? },
                   if: ->(obj){ obj.latitude.present? and obj.latitude_changed? and obj.longitude.present? and obj.longitude_changed? }
  #end CLHQ

  def search_and_fill_latlng(address=nil, locale=APP_CONFIG.default_locale)
    okresponse = false
    geocoder = "http://maps.googleapis.com/maps/api/geocode/json?address="

    if address == nil
      address = self.address
    end

    if address != nil && address != ""
      url = URI.escape(geocoder+address)
      resp = RestClient.get(url)
      result = JSON.parse(resp.body)

      if result["status"] == "OK"
        self.latitude = result["results"][0]["geometry"]["location"]["lat"]
        self.longitude = result["results"][0]["geometry"]["location"]["lng"]
        okresponse = true
      end
    end
    okresponse
  end

  def self.get_coords(latitude, longitude, distance)
    self.near([latitude, longitude], distance)
  end

  def new
    @latitude
    @longitude
  end
end
