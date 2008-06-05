class Asset
  def self.most_popular(limit=10, time_period=5.days.ago)
    popular = Listen.count(:all,:include => :asset, :group => 'listens.asset_id', :limit => limit, :conditions => ["listens.created_at > ? AND (listens.listener_id IS NULL OR listens.listener_id != listens.track_owner_id)", time_period], :order => 'count_all DESC')
    find(popular.collect{|pop| pop.first}, :include => :user)
    # In the last week, people have been listening to the following
    #find(:all, :include => :user, :limit => limit, :order => 'assets.listens_count DESC')
  end

  def self.days
    (Asset.sum(:length).to_f / 60 / 60 / 24).to_s[0..2]
  end
  
  def self.gigs
    (Asset.sum(:size).to_f / 1024 / 1024 / 1024).to_s[0..3]
  end
 
  def self.update_hotness
    Asset.find(:all).each do |a|
      a.update_attribute(:hotness, a.calculate_hotness)
    end 
  end
  
  def calculate_hotness
    # hotness = listens not originating from own user within last 7 days * num of alonetoners who listened to it / age
    ratio = ((recent_listen_count.to_f) * (((unique_listener_count * 10) / User.count) + 1) * age_ratio )
  end
  
  def recent_listen_count(from = 7.days.ago, to = 1.hour.ago)
   listens.count(:all, :conditions => ['listens.created_at > ? AND listens.created_at < ? AND listens.listener_id != ?',from, to, self.user_id]) 
  end
  
  def listens_per_day
    listens.count(:all, :conditions => ['listens.listener_id != ?', self.user_id]).to_f / days_old
  end
  
  def unique_listener_count
    listens.count(:listener_id, :distinct => true)
  end
  
  def days_old
    ((Time.now - created_at) / 60 / 60 / 24 ).ceil
  end
  
  def age_ratio
    case days_old
      when 0..3 then 20.0
      when 4..7 then 8.0
      when 8..15 then 3.0
      when 16..30 then 2.5
      when 31..90 then 1.0
      else 0.5
    end
  end  
end