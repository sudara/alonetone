APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]

class << APP_CONFIG
  APP_CONFIG.keys.each do |key|
    class_eval "def #{key}; APP_CONFIG['#{key}']; end"
  end  
end
