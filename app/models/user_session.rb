class UserSession < Authlogic::Session::Base
  record_selection_method :find_by_login_or_email

  # override authlogic's version of this to take into account @sudo
  def update_info
    unless controller.session[:sudo]
      record.last_login_at = record.current_login_at
      record.current_login_at = ActiveRecord.default_timezone == :utc ? Time.now.utc : Time.now
      record.last_login_ip = record.current_login_ip
      record.current_login_ip = controller.request.ip

      # update_info can be called before user and its associated profile is created
      record.profile&.update_attribute :user_agent, controller.request.user_agent
    end
  end
end
