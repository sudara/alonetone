class SecretzController < ApplicationController
  before_filter :login_required
  
  def index
    @ip_listens = Listen.most_active_ips
    @track_listens = Listen.most_active_tracks
    @users = User.with_same_ip
  end

end
