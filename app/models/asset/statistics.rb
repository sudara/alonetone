class Asset
  @@launch_date = 'Tue Jan 01 00:00:00 +0100 2008'.to_time

  def self.most_popular(limit=10, time_period=5.days.ago)
    popular = Listen.count(:all,
      :include => :asset, 
      :group => 'listens.asset_id', 
      :limit => limit, 
      :order => 'count_all DESC',
      :conditions => [
        "listens.created_at > ? AND " << 
        "(listens.listener_id IS NULL OR " <<
        "listens.listener_id != listens.track_owner_id)", 
        time_period ]
    )
    find(popular.collect{|pop| pop.first}, :include => :user)
    # In the last week, people have been listening to the following
    #find(:all, :include => :user, :limit => limit, :order => 'assets.listens_count DESC')
  end

  def self.days
    (Asset.sum(:length).to_f / 60 / 60 / 24).to_i.to_s
  end
  
  def self.gigs
    (Asset.sum(:size).to_f / 1024 / 1024 / 1024).to_s[0..3]
  end
 
  def self.update_hotness
    Asset.paginated_each do |a| # for some reason find_each doesn't work here...
      # These use update_all so that they do not trigger callbacks and invalidate cache
      Asset.update_all "hotness = #{a.calculate_hotness}", "id = #{a.id}"
      Asset.update_all "listens_per_week = #{a.listens_per_week}", "id = #{a.id}"
    end 
  end
  
  def calculate_hotness
    # hotness = listens not originating from own user within last 7 days * num of alonetoners who listened to it / age
    ratio = ((recent_listen_count.to_f) * (((unique_listener_count * 3) / User.count) + 1) * age_ratio )
  end
  
  def recent_listen_count(from = 7.days.ago, to = 1.hour.ago)
    listens.count(:all, 
      :conditions => [
        "listens.created_at > ? AND " << 
        "listens.created_at < ? AND " <<
        "listens.listener_id != ?",
        from, to, self.user_id
      ]) 
  end
  
  def listens_per_week
    listens.count(:all, 
      :conditions => ['listens.listener_id != ?', self.user_id]
    ).to_f * 7 / days_old
  rescue
    0
  end
  
  def unique_listener_count
    listens.count(:listener_id, :distinct => true)
  end
  
  def days_old
    ((Time.now - created_at) / 60 / 60 / 24 ).ceil
  end
  
  def age_ratio
    case days_old
      when 0..3 then 15.0
      when 4..7 then 7.0
      when 8..15 then 4.0
      when 16..30 then 2.5
      when 31..90 then 1.0
      else 0.5
    end
  end  
  
  def plays_by_month
    listens.count(:all, :group => 'MONTH(listens.created_at)', :include => nil, :conditions => ['listens.created_at > ?', 1.year.ago])
  end
  
  def self.monthly_chart
    monthly_counts = []
    sum_up_the_months(@@launch_date){|date, sum| monthly_counts << [sum, date]}
    monthly_counts
  end
  
  
  private 
  
  # iterate through the months
  def self.sum_up_the_months(date = Time.now, &block)    
    sum = 0
    while date < Time.now
      result, label = monthly_sum_for(date)
      sum = sum + result
      yield label, sum
      date += 1.month
    end
  end
  
  def self.monthly_sum_for(date=Time.now, sum=0)
    # [count, year_month_label]
    month_count = self.count(:all,
      :conditions => [
        'created_at > ? AND created_at < ?',
        date.beginning_of_month, 
        date.end_of_month
      ])
      
    [sum + month_count, "#{date.strftime('%b %y')}"]
  end
end