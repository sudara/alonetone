Bugsnag.configure do |config|
  config.release_stage = "production"
  config.api_key = Alonetone.try(:bugsnag_key)
  config.auto_capture_sessions = true
  config.ignore_classes << ActionController::UnknownFormat
  config.ignore_classes << ActiveRecord::RecordNotFound
end if Rails.env.production?
