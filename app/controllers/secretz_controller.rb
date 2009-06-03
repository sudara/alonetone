class SecretzController < ApplicationController
  before_filter :login_required
  
  def index
    @ip_listens = Listen.count_by_ip
    @track_listens = Listen.count_by_track
  end

end
