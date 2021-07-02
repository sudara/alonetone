class ProfilesController < ApplicationController
  before_action :require_login, :find_user

  def update
    @user.profile.update(profile_params)
    redirect_to edit_user_path(@user), ok: "Update your links", status: 303
  end

  protected

  def profile_params
    params[:profile].permit(:bio, :website, :twitter, :instagram, :bandcamp, :spotify, :apple, :youtube, :city, :country)
  end
end
