module Greenfield
  class ApplicationController < ActionController::Base
    include AuthlogicHelpers

    def nothing
      render nothing: true
    end

    def require_login(login=nil)
      @user_session = UserSession.new(login: login.try(:login))
      render 'greenfield/application/require_login'
    end

    def login
      @user_session = UserSession.new(params[:user_session].merge(remember_me: true))
      if @user_session.save
        redirect_to params[:continue]
      else
        flash[:message] = nil
        render action: :require_login
      end
    end
  end
end
