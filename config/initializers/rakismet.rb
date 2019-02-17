require 'rakismet'

if Rails.configuration.alonetone.rakismet_key.present?
  Rails.application.config.rakismet.key = Rails.configuration.alonetone.rakismet_key
  Rails.application.config.rakismet.url = Rails.configuration.alonetone.hostname

  module RakismetLog
    def akismet_call(function, args={})
      Rails.logger.warn("RAKISMET #{function}: #{args}")
      super
    end
  end

  Rakismet.singleton_class.prepend RakismetLog
end
