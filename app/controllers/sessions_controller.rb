class SessionsController < ApplicationController

  def new
    if logged_in?
      flash[:error] = "Either you aren't allowed to do that or you aren't allowed to do that"
      redirect_to (session[:return_to] || root_path)
    end
  end

  def create
   # if open_id?(params[:login])
   #   open_id_authentication params[:login]
   #else
      if params[:password]
        password_authentication params[:login], params[:password]
      else
        render :action => 'new'
      end
   #end
  end
  
  def destroy
    previous_page = session[:return_to]
    reset_session
    cookies.delete :auth_token
    flash[:ok] = "Goodbye, see you soon..."
    redirect_to (previous_page || root_path)
  end

  protected
    def open_id_authentication(identity_url)
      authenticate_with_open_id(identity_url, :required => [:nickname, :email], :optional => :fullname) do |status, identity_url, registration|
        case status
        when :missing
          failed_login "Sorry, the OpenID server couldn't be found"
        when :canceled
          failed_login "OpenID verification was canceled"
        when :failed
          failed_login "Sorry, the OpenID verification failed"
        when :successful
          if self.current_user = User.find_or_initialize_by_identity_url(identity_url)
            {'login=' => 'nickname', 'email=' => 'email', 'display_name=' => 'fullname'}.each do |attr, reg|
              current_user.send(attr, registration[reg]) unless registration[reg].blank?
            end
            unless current_user.save
              flash[:error] = "Error saving the fields from your OpenID profile at #{identity_url.inspect}: #{current_user.errors.full_messages.to_sentence}"
            end
            successful_login
          else
            failed_login "Sorry, no user by the identity URL #{identity_url.inspect} exists"
          end
        end
      end
    end

    def password_authentication(name, password)
      if self.current_user = User.authenticate(name, password)
        successful_login
      else
        failed_login "Yikes. That didn't work. Try again?"
      end
    end

    def successful_login
      cookies[:auth_token] = { :value => self.current_user.token , :expires => 2.weeks.from_now }
      flash[:ok] = "Welcome back to alonetone!"
      update_last_seen_at
      redirect_to_default
    end

    def failed_login(message)
      flash[:error] = message
      render :action => 'new'
    end
    
end
