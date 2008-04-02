# Add lat/lng info to each Place in the places table
class GeocodePlaces < ActiveRecord::Migration
  def self.up
    places = Place.find(:all)
    for place in places
      geo = GeoKit::Geocoders::MultiGeocoder.geocode("#{place.locality}, #{place.region}, #{place.postal_code}, #{place.country_name}")
      place.update_attributes(:lat => geo.lat, :lng => geo.lng)
    end      
  end

  def self.down
    Place.update_all('lat = NULL, lng = NULL')
  end
end
