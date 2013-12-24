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
    (Asset.sum(:mp3_file_size).to_f / 1024 / 1024 / 1024).to_s[0..3]
  end
 
  def self.update_hotness
    Asset.select(:id, :user_id, :created_at).find_each(:batch_size => 500) do |a| # for some reason find_each doesn't work here...
      # These use update_all so that they do not trigger callbacks and invalidate cache
      Asset.where(:id => a.id).update_all(:hotness => a.calculate_hotness, :listens_per_week => a.listens_per_week)
    end 
  end
   
  def calculate_hotness       
    (guest_play_count + (alonetoner_play_count * 2) + (unique_alonetoner_count * 4) - uncool_self_plays).to_f * age_ratio.to_f
  end
  
  # https://www.desmos.com/calculator/gwnliinim2
  # after about 20 listens, it "compresses" the value of guest listens
  def guest_play_count(from = 30.days.ago)
    num = listens.where("listens.created_at > (?) AND listens.listener_id is null",from).count 
    -7 + (0.19*num.to_f) + Math.log((num.to_f+5),1.25)
  end
  
  def listens_per_week
    listens.count(:all, 
      :conditions => ['listens.listener_id != ?', self.user_id]
    ).to_f * 7 / days_old
  rescue
    0
  end
  
  def uncool_self_plays(from = 30.days.ago)
    emphasis = 2.0
    allowance = 3.0
    uncool_plays = total_uncool_self_plays - allowance
    uncool_plays = (uncool_plays + uncool_plays.abs) / 2 # never want it to be below zero
    uncool_plays * emphasis
  end
  
  def total_uncool_self_plays(from = 30.days.ago)
    user_plays = listens.where(:listener_id => user.similar_users_by_ip).where("listens.created_at > (?)",from).count
  end
  
  def alonetoner_play_count(from = 30.days.ago)
    listens.where("listener_id is not null").where("listens.created_at > (?)",from).count.to_f - total_uncool_self_plays.to_f
  end
  
  def unique_alonetoner_count(from = 30.days.ago)
    alonetoners = listens.select('distinct listener_id').where("listens.created_at > (?)", from).count
    this_user = listens.select('distinct listener_id').where("listens.created_at > (?)", from).where(:listener_id => user.similar_users_by_ip).count
    total = alonetoners - this_user - 1 
    (total + total.abs) / 2 # ensure postitive number or zero
  end
  
  def bandwidth_used
    (listens.count * mp3_file_size).to_f / 1024 / 1024 / 1024
  end
  
  def days_old
    ((Time.now - created_at) / 60 / 60 / 24 ).ceil
  end
  
  def age_ratio
    case days_old
      when 0..1 then 100.0
      when 1..2 then 80.0
      when 2..3 then 70.0
      when 3..4 then 50.0
      when 5..7 then 35.0
      when 8..13 then 10.0
      when 14..30 then 2.0
      when 31..90 then 0.1
      else 0.01
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
