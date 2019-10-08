# frozen_string_literal: true

# Works just like the regular Rails Rack request logger, but silences all requests to the
# configured silenced request paths.
#
#   config.middleware.use(
#     FilteredRackLogger,
#     silenced: %w(/rails/active_storage)
#   )
class FilteredRackLogger < Rails::Rack::Logger
  def initialize(app, silenced:)
    super(app)
    @silenced = silenced
  end

  def call(env)
    if @silenced.any? { |path_prefix| env['PATH_INFO'].start_with?(path_prefix) }
      Rails.logger.silence { @app.call(env) }
    else
      super
    end
  end
end
