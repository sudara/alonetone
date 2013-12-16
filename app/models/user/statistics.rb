#require 'gchart'
class User
  
  def self.calculate_bandwidth_used
    User.select(:id, :created_at).find_each(:batch_size => 500) do |u|
      User.where(:id => u.id).update_all(:bandwidth_used => u.calculate_bandwidth_used)
    end
  end
  
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

    track_play_history = track_plays.group(group_by).where(created_within_30_days).count
    track_play_history.collect{ |tp| tp[1] }
    
   # ::Gchart.line(
   #   :size             => '420x150',
   #   :title            => 'listens',
   #   :data             => track_play_history,
   #   :axis_with_labels => 'r,x',
   #   :axis_labels      => [ GchartHelpers.zero_half_max(track_play_history.max), labels ],
   #   :line_colors      => 'cc3300', 
   #   :background       => '313327', 
   #   :custom           => 'chm=B,3d4030,0,0,0&chls=3,1,0&chg=25,50,1,0'
   # ) 
  end

    
  def listens_average
    first_created_at = assets.limit(1).order('created_at').first.created_at
    
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
    User.where(:id => most_listened_to_user_ids(10)).includes(:pic)
  end

  def calculate_bandwidth_used
    assets.sum(&:bandwidth_used).ceil # in gb
  end
  
  def total_bandwidth_cost
    # s3 is 12 cents a gig
    ActionController::Base.helpers.number_to_currency((bandwidth_used * 0.12), :unit => '$')
  end

  def most_listened_to_user_ids(limit = 10)
    listens
      .where(['track_owner_id != ? AND DATE(`listens`.created_at) > DATE_SUB( CURDATE(), interval 4 month)', self.id])
      .distinct(:track_owner_id)
      .group(:track_owner_id)
      .limit(limit)
      .order('count_track_owner_id DESC')
      .count(:track_owner_id).collect(&:first)
  end  

  
  def plays_since_last_session
    track_plays.between(self.last_session_at, Time.now.utc).count
  end
  
  def comments_since_last_session
    comments.between(last_session_at, Time.now.utc).count
  end
  
  def plays_by_month
    track_plays.count(:all, :group => 'MONTH(listens.created_at)', :include => nil, :conditions => ['listens.created_at > ?', 1.year.ago])
  end
  
  def self.with_same_ip
    User.order('count_all DESC').group(:last_login_ip).where('last_login_ip is not NULL').limit(25).count
  end

  

end
