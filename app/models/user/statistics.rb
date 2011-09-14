require 'gchart'
class User
  # graphing
  def track_plays_graph
    created_within_30_days = ['listens.created_at > ?', 30.days.ago.at_midnight]

    first_created = track_plays.minimum(:created_at, :conditions => created_within_30_days)
    first_created ||= Time.now
    seconds = (Time.now - first_created).round
    hours = seconds / 60 / 60
    days = hours / 24

    if days > 1
      labels = "#{days} days ago|#{(days+1)/2} days ago|Today"
      group_by = 'DATE(listens.created_at)'
    else
      labels = "#{hours} hours ago|#{(hours+1)/2} hours ago|Now"
      group_by = 'HOUR(listens.created_at)'
    end

    track_play_history = track_plays.count(:all, 
      :conditions => created_within_30_days, 
      :group      => group_by
    ).collect{ |tp| tp[1] }
    
    ::Gchart.line(
      :size             => '420x150',
      :title            => 'listens',
      :data             => track_play_history,
      :axis_with_labels => 'r,x',
      :axis_labels      => [ GchartHelpers.zero_half_max(track_play_history.max), labels ],
      :line_colors      => 'cc3300', 
      :background       => '313327', 
      :custom           => 'chm=B,3d4030,0,0,0&chls=3,1,0&chg=25,50,1,0'
    ) 
  end

    
  def assests_order_by(order)
    assets.find(:all, 
      :limit    => chart_limit, 
      :order    => order,
      :include  => []
    )
  end
  
  def most_favorited_chart
    create_chart(assests_order_by('favorites_count DESC'), :favorites_count)
  end
  
  def most_popular_chart
    create_chart(assests_order_by('hotness DESC'), :hotness)
  end 
  
  def most_listened_to_ever_chart
    create_chart(assests_order_by('listens_count DESC'), :listens_count)
  end
  
  def most_commented_on_chart
    create_chart(assests_order_by('comments_count DESC'), :comments_count)
  end
  
  def chart_limit
    assets_count > 5 ? 5 : assets_count
  end

  
  def create_chart(data_and_labels, counted)
    data   = data_and_labels.collect(&counted)
    labels = data_and_labels.collect{|a| ERB::Util.u(a.name)}.reverse.join('|')

    chart = Gchart.bar(
      :size             => '350x150', 
      :data             => data, 
      :background       => 'e1e2e1', 
      :orientation      => 'horizontal',
      :axis_with_labels => 'y,r',
      :axis_labels      => [labels,data.reverse.join('|')], 
      :line_colors      => 'cc3300'
    )
  rescue 
    ''
  end

  
  def listens_average
    first_created_at = assets.find(:all, 
      :limit => 1, 
      :order => 'created_at'
    ).first.created_at
    
    x = ((Time.now - first_created_at)  / 60 / 60 / 24 ).ceil
    
    (self.listens_count.to_f / x).ceil
  end
  
  def number_of_tracks_listened_to
    Listen.count(:all, 
      :order      => 'count_all DESC', 
      :conditions => {:listener_id => self}
    )
  end

  def mostly_listens_to
    User.find(most_listened_to_user_ids(10), :include => :pic)
  end

  def most_listened_to_user_ids(limit = 10)
    self.listens.count(:track_owner, 
      :group      =>  'track_owner_id',
      :order      =>  'count_track_owner DESC', 
      :limit      =>  limit, 
      :conditions => ['track_owner_id != ? AND DATE(`listens`.created_at) > DATE_SUB( CURDATE(), interval 4 month)', self.id]
    ).collect(&:first)
  end  

  
  def plays_since_last_session
    return false unless self.assets_count > 0
    count = Listen.count(:all, 
      :conditions => [ 'track_owner_id = ? AND created_at BETWEEN ? AND ?',
                       self.id, self.last_session_at, Time.now.utc ], 
      :include    => []
    )
    count > 0 ? count : false
  end
  
  
  def comments_since_last_session
    return false unless self.assets_count > 0
    count = Comment.count(:all, 
      :conditions => [ 'user_id = ? AND created_at BETWEEN ? AND ?',
                        self.id, self.last_session_at, Time.now.utc ], 
      :include    => []
    )
    count > 0 ? count : false
  end
  
  def plays_by_month
    track_plays.count(:all, :group => 'MONTH(listens.created_at)', :include => nil, :conditions => ['listens.created_at > ?', 1.year.ago])
  end
  
  def self.with_same_ip
    User.count(:all, 
              :group => 'ip', 
              :order => 'count_all DESC', 
              :conditions => 'ip is not NULL',
              :limit => 25)
  end

  

end