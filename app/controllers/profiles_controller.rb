class ProfilesController < ApplicationController
  before_action :require_login, :find_user

  def update
    @user.profile.update(profile_params)
    if @user.spam?
      @user.update(is_spam: @user.spam?)
      flash[:error] = "Hrm, robots marked you as spam. Your info will not appear on Alonetone. If this was done in error, please email support@alonetone.com and magic fairies will fix it right up."
    end

    redirect_back(fallback_location: edit_user_path(@user))
  end

  protected

  def profile_params
    params[:profile].permit(:bio, :website, :twitter, :instagram, :bandcamp, :spotify, :city, :country)
  end
end
