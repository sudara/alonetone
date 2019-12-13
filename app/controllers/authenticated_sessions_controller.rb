# frozen_string_literal: true

class AuthenticatedSessionsController < ApplicationController
  def new
    @page_title = "Login"
    @user = User.new
    @authenticated_session = AuthenticatedSession.new
  end

  def create
    @authenticated_session = AuthenticatedSession.new(authenticated_session_params)
    if @authenticated_session.save
      return redirect_back_or_default(user_home_path(@authenticated_session.user))
    elsif @authenticated_session.correct_password?
      flash.now[:error] = "It looks like your account is not active. <br/> Do you have an email from us with activation details?".html_safe
    else
      flash.now[:error] = "There was a problem logging you in! Please check your login and password."
    end

    render :new
  end

  def destroy
    if authenticated_session.destroy
      redirect_to login_path, notice: "We've logged you out. Your secrets are safe with us!"
    else
      redirect_to login_path, error: "You weren't logged in to begin with, old chap/dame!"
    end
  end

  private

  def authenticated_session_params
    params.require(:authenticated_session).permit(:login, :password).merge(session: session)
  end
end
