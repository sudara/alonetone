# Load up application config found in yml, make available as Alonetone.[settingname] for ease
# It needs to come before "class Application" to make paperclip happy
YAML.load_file("config/alonetone.yml")[Rails.env].each do |key, value|
  Alonetone.define_singleton_method(key.to_sym) { value } 
end

module Alonetone
  class << self
    alias_method :host, :url

    def url(request=nil)
      if request && Rails.env.development?
        "#{host}:#{request.port}"
      else
        host
      end
    end
  end
end
