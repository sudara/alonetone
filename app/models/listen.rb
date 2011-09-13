class Listen < ActiveRecord::Base
  
  @@launch_date = 'Tue Jan 01 00:00:00 +0100 2008'.to_time
  
  named_scope :from_user, {:conditions => ['listener_id != ""']}
  named_scope :downloads, {:conditions => {:source => 'download'}}  
  # A "Listen" occurs when a user listens to another users track
  belongs_to :asset, :counter_cache => true, :touch => true

  belongs_to :listener, 
    :class_name     => 'User', 
    :foreign_key    => 'listener_id'

  belongs_to :track_owner, 
    :class_name     => 'User', 
    :counter_cache  => true
  
  validates_presence_of :asset_id, :track_owner_id

  reportable :weekly, :aggregation => :count, :grouping => :week
  
  
  def source
    self[:source] || 'alonetone'
  end
  
  def self.total
    count(:all)
  end
  
  def self.today
    count(:all, :conditions => {:created_at => Time.now.at_beginning_of_day..Time.now})
  end

  
  def self.count_within_a_month(options={})
    options[:conditions] = ['listens.created_at > ?', 30.days.ago.at_midnight]
    count(:all, options)
  end
  
  def self.source_chart
    data = count_within_a_month(
      :group => :source, 
      :order => 'count_all DESC', 
      :limit => 10
    )    

    various = count_within_a_month - data.collect(&:last).sum

    data['various other sources'] = various
    data
  end
  
  def self.monthly_chart
    monthly_counts = []
    count_back_the_months(Time.now.months_ago(1)) { |month| 
      monthly_counts << self.monthly_listen_count_for(month) 
    }
    monthly_counts
  end
  
  def self.last_30_days_chart
    data = self.count :all, 
      :conditions => ['listens.created_at > ?', 30.days.ago.at_midnight], 
      :group => 'DATE(listens.created_at)' 
      
    data = data.collect(&:last)

    chart = Gchart.line(
      :size             => '500x150',
      :data             => data,
      :background       => 'e1e2e1',
      :axis_with_labels => 'r,x',
      :axis_labels      => [ GchartHelpers.zero_half_max(data.max), 
                             "30 days ago|15 days ago|Today" ],
      :line_colors      =>'cc3300',
      :custom           => 'chm=B,ff9933,0,0,0'
    )
  end
  
  def self.most_active_ips(limit=25)
    Listen.count(:all, :group => :ip, :conditions => ['created_at > ?',30.days.ago], :order => 'count_all DESC', :limit => limit)
  end
  
  def self.most_active_tracks(limit=25)
    Listen.count(:all, 
                 :from => "listens IGNORE INDEX(index_listens_on_asset_id)",
                 :group => :asset, 
                 :conditions => ['created_at > ?',30.days.ago], :order => 'count_all DESC', :limit => limit)
  end
  
  def self.find_user_by_ip(ip)
    Listen.find(:first, :conditions => ['ip = ? AND listener_id IS NOT NULL',ip]).listener rescue nil
  end
  
  protected
  
  # iterate through the months
  def self.count_back_the_months(date = Time.now, &block)
    # throw back the first date
    yield date
    
    # now, decrease by one month until we hit the start
    count_back_the_months(date.months_ago(1),&block) if date > @@launch_date
  end
  
  
  def self.monthly_listen_count_for(date=Time.now)
    # [count, year_month_label]
    [ Listen.count(:all, 
        :conditions => ['created_at > ? AND created_at < ?', 
                        date.beginning_of_month, date.end_of_month]
      ), 
      "#{date.strftime('%b %y')}" ]
  end
end