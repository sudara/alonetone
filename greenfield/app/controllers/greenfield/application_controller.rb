module Greenfield
  class ApplicationController < ActionController::Base
    include AuthlogicHelpers

    protected

    def attempt_login_via_alonetone
      render 'layouts/greenfield/login_via_alonetone', :layout => nil
    end
  end
end
