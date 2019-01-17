module Greenfield
  class Constraints
    def self.matches?(request)
      request.host =~ /^(www\.)?#{Rails.configuration.alonetone.greenfield_hostname}$/
    end
  end
end
