class GeocodeUsers < ActiveRecord::Migration
  def self.up
    User.with_location.each{|u| geocode_address(user) }
  end

  def self.down
  end

  def self.geocode_address(user)
    return unless user.city && user.country

    geo = GeoKit::Geocoders::MultiGeocoder.geocode([user.city, user.country].compact.join(', '))

    if geo.success
      user.update_attributes(lat: geo.lat, lng: geo.lng)
    end
  end
end
