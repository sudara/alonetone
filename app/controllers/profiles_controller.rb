class ProfilesController < ApplicationController
  before_action :require_login, :find_user

  def update
    @user.profile.update(profile_params)
    if @user.spam?
      @user.is_spam = true
      # delete all user's associations
      @user.soft_delete_with_relations
      flash[:error] = "Hrm, robots marked you as spam. If this was done in error, please email support@alonetone.com and magic fairies will fix it right up."
      redirect_to logout_path
    else
      redirect_back(fallback_location: edit_user_path(@user))
    end
  end

  protected

  def profile_params
    params[:profile].permit(:bio, :website, :twitter, :instagram, :bandcamp, :spotify, :city, :country)
  end
end
