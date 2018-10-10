class NotificationsController < ApplicationController
  before_action :require_login

  def subscribe
    current_user.settings[:email_new_tracks] = true
    current_user.save!
    flash[:ok] = "Email notifications re-enabled."
    redirect_to root_path
  end

  def unsubscribe
    current_user.settings[:email_new_tracks] = false
    current_user.save!
    flash[:ok] = "You've been unsubscribed from email notifications.
                   #{view_context.link_to 'Undo', '/notifications/subscribe'}"
    redirect_to root_path
  end
end
