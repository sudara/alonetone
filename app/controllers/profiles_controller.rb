class ProfilesController < ApplicationController
  before_action :require_login, :find_user

  def update
    @user.profile.update_attributes(profile_params)
    redirect_back(fallback_location: edit_user_path(@user))
  end

  protected

  def profile_params
    params[:profile].permit(:bio, :website, :twitter, :instagram, :bandcamp, :spotify, :city, :country)
  end
end
