require 'rakismet'

if Rails.configuration.alonetone.rakismet_key.present?
  Rails.application.config.rakismet.key = Rails.configuration.alonetone.rakismet_key
  Rails.application.config.rakismet.url = Rails.configuration.alonetone.hostname
end

module RakismetCallGuard
  def akismet_call(function, args = {})
    return 'false' if key.blank?

    Rails.logger.warn("RAKISMET #{function}: #{args}")
    super
  end
end

Rakismet.singleton_class.prepend RakismetCallGuard
