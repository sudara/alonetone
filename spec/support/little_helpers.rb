module RSpec
  module Support
    module LittleHelpers
      def last_email
        ActionMailer::Base.deliveries.last
      end
    end
  end
end