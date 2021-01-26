class NotificationsController < ApplicationController
  before_action :require_login

  def subscribe
    current_user.settings.update(email_new_tracks: true)
    flash[:ok] = "Email notifications on track uploads re-enabled."
    redirect_to root_path
  end

  def unsubscribe
    current_user.settings.update(email_new_tracks: false)
    current_user.save!
    flash[:ok] = "You will no longer be emailed when someone you follow uploads!
                   #{view_context.link_to 'Undo', '/notifications/subscribe'}"
    redirect_to root_path
  end
end
