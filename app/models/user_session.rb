class UserSession < Authlogic::Session::Base
  
  # override authlogic's version of this to take into account @sudo
  def update_info
    if record.respond_to?(:current_login_at) && !controller.session[:sudo]
      record.last_login_at = record.current_login_at if record.respond_to?(:last_login_at)
      record.current_login_at = klass.default_timezone == :utc ? Time.now.utc : Time.now
    end

    if record.respond_to?(:current_login_ip) && !controller.session[:sudo]
      record.last_login_ip = record.current_login_ip if record.respond_to?(:last_login_ip)
      record.current_login_ip = controller.request.ip
    end
  end
end
