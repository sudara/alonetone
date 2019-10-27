Bugsnag.configure do |config|
  config.logger.level = Logger::ERROR # Don't be noisy in dev/test
  config.notify_release_stages = ['production']
  config.api_key = Rails.configuration.alonetone.bugsnag_api_key
  config.auto_capture_sessions = true

  # Controller does not implement the action that was requested; happens when
  # someone hits an action because overmatching routes.
  config.ignore_classes << AbstractController::ActionNotFound

  # Action does not support for a certain format (e.g. xml); happens when
  # someone hits an action with a weird accept header or adds the format
  # param with an unsupported value.
  config.ignore_classes << ActionController::UnknownFormat

  # When a model doesn't find a record; this already renders a 404 and is not
  # really interesting.
  config.ignore_classes << ActiveRecord::RecordNotFound
end
