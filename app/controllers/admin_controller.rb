class AdminController < ApplicationController
  before_action :moderator_only, only: 'secretz'

  def toggle_theme
    if logged_in?
      current_user.toggle! :white_theme_enabled
    else 
      session[:white] = !session.try(:white)
    end
    redirect_back(fallback_location: root_path)
  end

  def secretz
    @ip_listens = Listen.most_active_ips
    @same_ip_users = User.with_same_ip
    @track_listens = Listen.most_active_tracks
    @all_time_track_listens = Asset.order('listens_count DESC').limit(25)
    @expensive_users = User.order('bandwidth_used desc').limit(25)
  end
end
