class Place < ActiveRecord::Base
  has_many :memberships, :dependent => true
  has_many :people, :through => :memberships
  
  acts_as_mappable
  acts_as_ferret    :fields => [:org, :locality, :postal_code, :region]
  
  before_validation_on_create :geocode_address
  
private
  
  def geocode_address
    geo = GeoKit::Geocoders::MultiGeocoder.geocode("#{self.street_address}, #{self.locality}, #{self.region}, #{self.postal_code}")
    errors.add(:locality, "Could not Geocode address") if !geo.success
    self.lat, self.lng = geo.lat, geo.lng if geo.success
  end  
  
end