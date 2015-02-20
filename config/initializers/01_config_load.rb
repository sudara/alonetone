# Load up application config found in yml, make available as Alonetone.[settingname] for ease
# It needs to come before "class Application" to make paperclip happy
YAML.load_file("config/alonetone.yml")[Rails.env].each do |key, value|
  Alonetone.define_singleton_method(key.to_sym) { value } 
end