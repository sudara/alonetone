class UserSession < Authlogic::Session::Base
  find_by_login_method :find_by_login_or_email

  # override authlogic's version of this to take into account @sudo
  def update_info
    if !controller.session[:sudo]
      record.last_login_at = record.current_login_at
      record.current_login_at = klass.default_timezone == :utc ? Time.now.utc : Time.now
      record.last_login_ip = record.current_login_ip
      record.current_login_ip = controller.request.ip
      # update_info can be called before user and it's associated profile is created
      if record.profile
        record.profile.update_attribute :user_agent, controller.request.user_agent
      end
    end
  end
end
