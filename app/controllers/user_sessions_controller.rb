class UserSessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, :if => :attempting_greenfield_login_via_alonetone?

  def new
    @page_title = "Login"
    @user = User.new
    @user_session = UserSession.new
    @bypass_recaptcha = true unless RECAPTCHA_ENABLED
  end

  def create
    @user_session = UserSession.new(params[:user_session].merge({:remember_me => true})) #always stay logged in
    if @user_session.save
      redirect_back_or_default(user_home_path(@user_session.user))
    else
      if params[:user_session][:login] && (user = User.find_by_login(params[:user_session][:login])) && !user.active?
        flash.now[:error] = "It looks like your account is not active. <br/> Do you have an email from us with activation details?".html_safe
      else
        flash.now[:error] = "There was a problem logging you in! Please check your login and password."
      end
      @user = User.new
      @bypass_recaptcha = true unless RECAPTCHA_ENABLED
      render :action => :new
    end
  end

  def destroy
    if logged_in?
      current_user_session.destroy
      redirect_to login_path, :notice => "We've logged you out. Your secrets are safe with us!"
    else
      redirect_to login_path, :error => "You weren't logged in to begin with, old chap/dame!"
    end
  end

  def greenfield_login
    if current_user
      verifier = ActiveSupport::MessageVerifier.new(Alonetone.secret)
      @token = verifier.generate([current_user.id, 1.minute.from_now])
    end
  end

  def create_from_token
    verifier = ActiveSupport::MessageVerifier.new(Alonetone.secret)
    user_id, time = verifier.verify(params[:token])
    if Time.now < time
      UserSession.create(User.find(user_id), true)
      render :nothing => true
    else
      render :nothing => true, :status => :unauthorized
    end
  end

  private

  def attempting_greenfield_login_via_alonetone?
    ['greenfield_login', 'create_from_token'].include?(action_name) &&
      URI(request.referer).host == Alonetone.greenfield_url
  end
end
