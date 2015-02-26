module Greenfield
  class Constraints
    def self.matches?(request)
      request.host =~ /^(www\.)?#{Alonetone.greenfield_url}$/
    end
  end
end
