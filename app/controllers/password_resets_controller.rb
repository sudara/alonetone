# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  before_action :find_user, only: %i[edit update]

  def create
    if user = User.find_by(email: params[:email])
      authentication_token = user.authentication_tokens.password_reset.create
      UserNotification.forgot_password(@user, authentication_token.token).deliver_now
    end
    flash[:notice] = "Check your email and click the link to reset your password!"
    redirect_to login_path
  end

  def update
    User.transaction do
      if @user.update(password_params)
        @authentication_token.destroy
        @user.update_account_request!
        UserSession.create(@user, true)
        flash[:notice] = "Phew, we were worried about you. Welcome back."
        redirect_to user_home_path(@user.login)
      else
        render :edit
      end
    end
  end

  private

  def find_user
    @authentication_token = AuthenticationToken.password_reset.find_by!(token: params[:token])
    @user = @authentication_token.user
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
