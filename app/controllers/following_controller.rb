class FollowingController < ApplicationController
  before_action :require_login, :find_user, :redirect_on_self_attempt

  def follow
    if !current_user.is_following? @user
      current_user.add_or_remove_followee(@user.id)
      flash[:ok] = "You've followed #{@user.name}!
                    #{view_context.link_to 'Undo', unfollow_path(@user.login)}"
      redirect_to root_path
    else
      flash[:error] = "You're already following #{@user.name}"
      redirect_to root_path
    end
  end

  def unfollow
    if current_user.is_following? @user
      current_user.add_or_remove_followee(@user.id)
      flash[:ok] = "You've unfollowed #{@user.name}!
                    #{view_context.link_to 'Undo', follow_path(@user.login)}"
      redirect_to root_path
    else
      flash[:error] = "You're not following #{@user.name}"
      redirect_to root_path
    end
  end

  def toggle_follow
    current_user.add_or_remove_followee(@user.id)
    head :ok
  end

  private

  def redirect_on_self_attempt
    redirect_to root_path if current_user == @user
  end
end
