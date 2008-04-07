# == Schema Information
# Schema version: 16
#
# Table name: listens
#
#  id         :integer(11)   not null, primary key
#  asset_id   :integer(11)   
#  user_id    :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Listen < ActiveRecord::Base
  
  @@launch_date = 'Tue Jan 01 00:00:00 +0100 2008'.to_time
  
  # A "Listen" occurs when a user listens to another users track
  belongs_to :asset, :counter_cache => true
  
  belongs_to :listener, :class_name => 'User', :foreign_key => 'listener_id'
  belongs_to :track_owner, :class_name => 'User', :counter_cache => true
  
  validates_presence_of :asset_id, :track_owner_id
  
  def source
    self[:source] || 'alonetone'
  end
  
  def self.source_chart
    data = Listen.count(:all, :group => :source, :order => 'count_all DESC', :limit => 8, :conditions => ['listens.created_at > ?',30.days.ago.at_midnight])
    various = Listen.count(:all, :conditions => ['listens.created_at > ?',30.days.ago.at_midnight]) - data.collect(&:last).sum
    data << ['various other sources', various]
    Gchart.pie(:size => '500x125', :background => 'e1e2e1', :data => data.collect(&:last), :labels => data.collect{|d| CGI.escape(d.first.to_s)})
  end
  
  def self.monthly_chart
    monthly_counts = []
    count_back_the_months(Time.now.months_ago(1)){|month| monthly_counts << self.monthly_listen_count_for(month) }
    data = monthly_counts.collect(&:first).reverse
    labels = monthly_counts.collect(&:last).reverse
    chart = Gchart.line(:size => '500x150', :data => data, :background => 'e1e2e1', :axis_with_labels => 'r,x', :axis_labels => ["0|#{(data.max.to_f/2).round}|#{data.max}","#{labels.join('|')}"], :line_colors =>'cc3300', :custom => 'chm=B,ff9933,0,0,0' )
  end
  
  def self.last_30_days_chart
    data = Listen.count :all, :conditions => ['listens.created_at > ?',30.days.ago.at_midnight], :group => 'DATE(listens.created_at)' 
    data = data.collect(&:last)
    chart = Gchart.line(:size => '500x150', :data => data, :background => 'e1e2e1', :axis_with_labels => 'r,x', :axis_labels => ["0|#{(data.max.to_f/2).round}|#{data.max}","30 days ago|15 days ago|Today"], :line_colors =>'cc3300', :custom => 'chm=B,ff9933,0,0,0' )
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
    [Listen.count(:all, :conditions => ['created_at > ? AND created_at < ?',date.beginning_of_month, date.end_of_month]), "#{date.strftime('%b %y')}"]
  end
  

end
