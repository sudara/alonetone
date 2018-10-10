class FollowingController < ApplicationController
  before_action :require_login, :redirect_if_current_user_equals_params

  def follow
    followee = User.find_by!(login: params[:login])

    if already_following?(followee.id)
      flash[:error] = "You're already following #{followee.name}!"
      return redirect_to root_path
    end

    current_user.add_or_remove_followee(followee.id)
    flash[:ok] = "You've followed #{followee.name}!
                   #{view_context.link_to 'Undo', '/unfollow/' + followee.login}"
    redirect_to root_path
  end

  def unfollow
    followee = User.find_by!(login: params[:login])

    if not_already_following?(followee.id)
      flash[:error] = "You're not following #{followee.name}!"
      return redirect_to root_path
    end

    current_user.add_or_remove_followee(followee.id)
    flash[:ok] = "You've unfollowed #{followee.name}! 
                   #{view_context.link_to 'Undo', '/follow/' + followee.login}"
    redirect_to root_path
  end

  private

  def redirect_if_current_user_equals_params
    redirect_to root_path if current_user.login == params[:login].downcase
  end

  def already_following?(followee_id)
    current_user.is_following?(followee_id)
  end

  def not_already_following?(followee_id)
    !current_user.is_following?(followee_id)
  end
end
