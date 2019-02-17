if api_key = Rails.configuration.alonetone.bugsnag_api_key
  Bugsnag.configure do |config|
    config.release_stage = "production"
    config.api_key = api_key
    config.auto_capture_sessions = true
    config.ignore_classes << ActionController::UnknownFormat
    config.ignore_classes << ActiveRecord::RecordNotFound
  end
end
