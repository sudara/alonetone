ALONETONE = YAML.load_file("#{RAILS_ROOT}/config/alonetone.yml")[RAILS_ENV]

class << ALONETONE
  ALONETONE.keys.each do |key|
    class_eval "def #{key}; ALONETONE['#{key}']; end"
  end  
end
  