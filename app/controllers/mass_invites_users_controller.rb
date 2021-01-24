# frozen_string_literal: true

class MassInvitesUsersController < ApplicationController
  include UserCreation

  before_action lambda {
    @mass_invite = MassInvite.find_by!(token: params[:mass_invite_token])
    render :archived if @mass_invite.archived?
  }

  def new
    @user = User.new
  end

  def create
    @user = @mass_invite.users.new(user_params)
    respond_with_user(@user)
  end

  def show
    redirect_to new_mass_invite_users_url(@mass_invite)
  end

  private

  def user_params
    params.require(:user).permit(:email, :login, :password, :password_confirmation)
  end
end
