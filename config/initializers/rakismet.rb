require 'rakismet'
if Alonetone.rakismet_key
  RAKISMET_ENABLED = true
  Alonetone::Application.config.rakismet.key = Alonetone.rakismet_key
  Alonetone::Application.config.rakismet.url = Alonetone.url
else
  RAKISMET_ENABLED = false
end

module RakismetLog
  def akismet_call(function, args={})
    Rails.logger.warn("RAKISMET #{function}: #{args}")
    super
  end
end

Rakismet.singleton_class.prepend RakismetLog
