# Wonderful code cleanliness helper care of Rick. Needs update for rails 3?
class << ActiveRecord::Base
  def concerned_with(*concerns)
    concerns.each do |concern|
      require_dependency "#{name.underscore}/#{concern}"
    end
  end
end
