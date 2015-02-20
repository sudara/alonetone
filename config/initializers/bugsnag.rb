Bugsnag.configure do |config|
  config.release_stage = "production"
  config.api_key = Alonetone.try(:bugsnag_key)
end
