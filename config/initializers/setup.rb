
# you are working with git
SVN_COMMAND = 'svn info'
BRIGHTNESS = ''
LASTCHANGED = Date.today

# MAKE FACEBOOKER HAPPY
ActionController::Base.asset_host = ''

# FLASH STUFF
FLASH_PLAYER = 'http://alonetone.com/flash/alonetone_player.swf'

# MAILER STUFF

UserMailer.default_url_options[:host] = 'alonetone.com'
UserMailer.mail_from = 'music@alonetone.com'

# GENERATE THE NEEDED CSS STYLESHEETS
Sass::Plugin.options[:always_check] = true 

require 'randomness'
require 'goodies'
require 'utils'
PASSWORD_SALT = 'so_salty_its_unbearable'

# DEPENDENCIES 
begin 
  require 'mp3info'
  require 'zip/zip'
  require 'gchart'
rescue
  raise GemInstallNeeded
end

WillPaginate::ViewHelpers.pagination_options[:inner_window] = 2
WillPaginate::ViewHelpers.pagination_options[:outer_window] = 0

# Take advantage of rails 2.1
ActiveRecord::Base.partial_updates = true


# These defaults are used in GeoKit::Mappable.distance_to and in acts_as_mappable
GeoKit::default_units = :miles
GeoKit::default_formula = :sphere

# This is the timeout value in seconds to be used for calls to the geocoder web
# services.  For no timeout at all, comment out the setting.  The timeout unit
# is in seconds. 
GeoKit::Geocoders::timeout = 2

# This is your Google Maps geocoder key. 
# See http://www.google.com/apis/maps/signup.html
# and http://www.google.com/apis/maps/documentation/#Geocoding_Examples  
GeoKit::Geocoders::google = 'ABQIAAAAb7vQ1d8XHrxuF5AJr8c-oxTbnWe9oX1zcTcDyLcGskh9JPynnBQ3ngxc6atkyQFihW5nLKpXFQ58gQ'


# This is the order in which the geocoders are called in a failover scenario
# If you only want to use a single geocoder, put a single symbol in the array.
# Valid symbols are :google, :yahoo, :us, and :ca.
# Be aware that there are Terms of Use restrictions on how you can use the 
# various geocoders.  Make sure you read up on relevant Terms of Use for each
# geocoder you are going to use.
GeoKit::Geocoders::provider_order = [:google]
