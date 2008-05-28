class GeocodeUsers < ActiveRecord::Migration
  def self.up
    User.with_location.each{|u| u.geocode_address; u.save }
  end

  def self.down
  end
end
