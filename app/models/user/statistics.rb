class User
  # graphing
  def track_plays_graph
    Gchart.line(:size => '420x150',:title => 'listens', :data => track_play_history, :axis_with_labels => 'r,x', :axis_labels => ["0|#{(track_play_history.max.to_f/2).round}|#{track_play_history.max}","30 days ago|15 days ago|Today"], :line_colors =>'cc3300', :background => '313327', :custom => 'chm=B,3d4030,0,0,0&chls=3,1,0&chg=25,50,1,0') 
  end
  
  def track_play_history
    track_plays.count(:all, :conditions => ['listens.created_at > ?',30.days.ago.at_midnight], :group => 'DATE(listens.created_at)').collect{|tp| tp[1]}
  end
  
  def listens_average
    (self.listens_count.to_f / ((((Time.now - self.assets.find(:all, :limit => 1, :order => 'created_at').first.created_at)  / 60 / 60 / 24 )).ceil)).ceil
  end
  
  def number_of_tracks_listened_to
    Listen.count(:all, :order => 'count_all DESC', :conditions => {:listener_id => self})
  end
  
  def mostly_listens_to
    User.find(most_listened_to_user_ids(10), :include => :pic)
  end
  
  def most_listened_to_user_ids(limit = 10)
    self.listens.count(:track_owner, :group => 'track_owner_id', 
      :order => 'count_track_owner DESC', 
      :limit => limit, 
      :conditions => ['track_owner_id != ?',self.id]).collect(&:first)
  end  
end