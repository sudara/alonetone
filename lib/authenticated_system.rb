module AuthenticatedSystem
  protected
    # this is used to keep track of the last time a user has been seen (reading a topic)
    # it is used to know when topics are new or old and which should have the green
    # activity light next to them
    #
    # we cheat by not calling it all the time, but rather only when a user views a topic
    # which means it isn't truly "last seen at" but it does serve it's intended purpose
    #
    # this could be a filter for the entire app and keep with it's true meaning, but that 
    # would just slow things down without any forseeable benefit since we already know 
    # who is online from the user/session connection 
    #
    # This is now also used to show which users are online... not at accurate as the
    # session based approach, but less code and less overhead.
    def update_last_seen_at
      return unless logged_in? 
      current_user.update_attribute(:last_seen_at,Time.now.utc)
      current_user.update_attribute(:ip, request.remote_ip)
    end
    
    def login_required
      login_from_session unless logged_in?
      login_by_token unless logged_in?
      get_auth_data unless logged_in?
      respond_to do |format| 
        format.html do
          store_location
          redirect_to :controller => '/sessions', :action => 'new'
        end
        format.js   { render(:update) { |p| p.redirect_to login_path } }
        format.xml  do
          headers["WWW-Authenticate"] = %(Basic realm="Future Is Bright")
          render :text => "HTTP Basic: Access denied.\n", :status => :unauthorized
        end
      end unless authorized?
      false
    end
    
    def login_by_token
      @welcome_back = true if logged_in? && self.current_user.hasnt_been_here_in(3.hours)

      return unless cookies[:auth_token] && !logged_in?
      user = cookies[:auth_token] && User.find_by_token(cookies[:auth_token])
      if user && user.token?
        cookies[:auth_token] = { :value => user.token, :expires => 2.weeks.from_now }
        self.current_user = user
        update_last_session_at
      end    
    end
    
    def login_from_session
      if session[:user]
        self.current_user = User.find(session[:user]) 
        update_last_session_at
      end
    end
    
    def welcome_back?
      @welcome_back
    end
    
    def update_last_session_at
      if self.current_user
        # when the user last was on alonetone (used for stats, highlighting what's new)
        self.current_user.update_attribute(:last_session_at, self.current_user.last_seen_at)
      end
    end
    
    def default_url
      url = user_home_path(current_user) if logged_in? 
      url = login_url if !url
      url
    end
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_to_default
      redirect_to(session[:return_to] || default_url)
      session[:return_to] = nil
    end
    
    def authorized?() 
      logged_in?
    end

    def current_user=(new_user)
      if @current_user = new_user
        # this is used while we're logged in to know which threads are new, etc
        session[:last_active] = @current_user.last_seen_at unless session[:sudo]
        session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
        @current_user = new_user || false
        update_last_seen_at unless session[:sudo]
      end
    end

    def current_user
      @current_user ||= ((session[:user] && User.find_by_id(session[:user])) || false)
    end
    
    def logged_in?
      current_user != false
    end
    
    def admin?
      logged_in? && current_user.admin?
    end
        
    private
      @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
      # gets BASIC auth info
      def get_auth_data
        auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
        auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
        return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
      end
end