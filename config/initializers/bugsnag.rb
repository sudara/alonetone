Bugsnag.configure do |config|
  config.release_stage = "production"
  config.api_key = Alonetone.try(:bugsnag_key)
  config.auto_capture_sessions = true
end if Rails.env.production?
