# -*- encoding : utf-8 -*-
class UserSessionsController < ApplicationController
  def new
    @page_title = "Login"
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session].merge({:remember_me => true})) #always stay logged in
    if @user_session.save
      if request.xhr?
        render :nothing => true, :status => 200
      else
        redirect_back_or_default default_login_path
      end
    else
      if request.xhr?
        render :text => "Login Failed", :status => 401
      else
        flash.now[:error] = "There was a problem logging you in! Please re-check your email and password."
        render :action => :new
      end
    end
  end

  def destroy
    if logged_in?
      current_user_session.destroy
      redirect_to new_user_session_url, :notice => "We've logged you out. Your secrets are safe with us!"
    else
      redirect_to login_path
    end
  end
end
