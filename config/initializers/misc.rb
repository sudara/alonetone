FLASH_PLAYER = 'http://alonetone.com/flash/alonetone_player.swf'

require 'authlogic_helpers'
require 'sometimes'

WillPaginate::ViewHelpers.pagination_options[:inner_window] = 2
WillPaginate::ViewHelpers.pagination_options[:outer_window] = 0

# These defaults are used in Geokit::Mappable.distance_to and in acts_as_mappable
Geokit::default_units = :miles
Geokit::default_formula = :sphere

# This is the timeout value in seconds to be used for calls to the geocoder web
# services.  For no timeout at all, comment out the setting.  The timeout unit
# is in seconds.
Geokit::Geocoders::request_timeout = 2

# This is your Google Maps geocoder key.
# See http://www.google.com/apis/maps/signup.html
# and http://www.google.com/apis/maps/documentation/#Geocoding_Examples
Geokit::Geocoders::GoogleGeocoder.api_key =
  'ABQIAAAAb7vQ1d8XHrxuF5AJr8c-oxTbnWe9oX1zcTcDyLcGskh9JPynnBQ3ngxc6atkyQFihW5nLKpXFQ58gQ'


# This is the order in which the geocoders are called in a failover scenario
# If you only want to use a single geocoder, put a single symbol in the array.
# Valid symbols are :google, :yahoo, :us, and :ca.
# Be aware that there are Terms of Use restrictions on how you can use the
# various geocoders.  Make sure you read up on relevant Terms of Use for each
# geocoder you are going to use.
Geokit::Geocoders::provider_order = [:google]

