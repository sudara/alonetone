class Listen < ActiveRecord::Base
  @@launch_date = 'Tue Jan 01 00:00:00 +0100 2008'.to_time

  scope :from_user,  -> { where('listener_id != ""') }
  scope :downloads,  -> { where(source: 'download') }
  scope :between,    ->(start, finish) { where('listens.created_at BETWEEN ? AND ?', start, finish) }
  scope :since,      ->(date) { where('listens.created_at > ?', date) }

  # A "Listen" occurs when a user listens to another users track
  belongs_to :asset, counter_cache: true, touch: true

  belongs_to :listener, class_name: 'User', foreign_key: 'listener_id', optional: true

  belongs_to :track_owner, class_name: 'User', counter_cache: true

  before_save :truncate_user_agent

  def source
    self[:source] || 'direct hit'
  end

  def self.total
    count(:all)
  end

  def self.today
    where(created_at: Time.now.at_beginning_of_day..Time.now).count
  end

  def self.count_within_a_month(options = {})
    options[:conditions] = ['listens.created_at > ?', 30.days.ago.at_midnight]
    count(:all, options)
  end

  def self.source_chart
    data = count_within_a_month(
      group: :source,
      order: 'count_all DESC',
      limit: 10
    )

    various = count_within_a_month - data.collect(&:last).sum

    data['various other sources'] = various
    data
  end

  def self.monthly_chart
    monthly_counts = []
    count_back_the_months(Time.now.months_ago(1)) { |month|
      monthly_counts << monthly_listen_count_for(month)
    }
    monthly_counts
  end

  def self.last_30_days_chart
    data = count :all,
      conditions: ['listens.created_at > ?', 30.days.ago.at_midnight],
      group: 'DATE(listens.created_at)'

    data = data.collect(&:last)

    chart = Gchart.line(
      size: '500x150',
      data: data,
      background: 'e1e2e1',
      axis_with_labels: 'r,x',
      axis_labels: [GchartHelpers.zero_half_max(data.max),
                             "30 days ago|15 days ago|Today"],
      line_colors: 'cc3300',
      custom: 'chm=B,ff9933,0,0,0'
    )
  end

  def self.most_active_ips(limit = 25)
    Listen.where('created_at > ?', 30.days.ago)
          .order('count_all DESC')
          .group(:ip).limit(limit).count
  end

  def self.most_active_tracks(limit = 25)
    Listen.from('listens IGNORE INDEX(index_listens_on_asset_id)')
          .where('created_at > ?', 30.days.ago).order('count_all DESC')
          .group(:asset).limit(limit).count
  end

  def self.find_user_by_ip(ip)
      Listen.find(:first, conditions: ['ip = ? AND listener_id IS NOT NULL', ip]).listener
  rescue StandardError
      nil
  end

  protected

  # iterate through the months
  def self.count_back_the_months(date = Time.now, &block)
    # throw back the first date
    yield date

    # now, decrease by one month until we hit the start
    count_back_the_months(date.months_ago(1), &block) if date > @@launch_date
  end

  def self.monthly_listen_count_for(date = Time.now)
    # returns [count, year_month_label]
    [Listen.where('created_at > ? AND created_at < ?',
       date.beginning_of_month, date.end_of_month).count,
      date.strftime('%b %y').to_s]
  end

  def truncate_user_agent
    self.user_agent = user_agent.try(:slice, 0, 255)
    self.source = source.try(:slice, 0, 255)
  end
end

# == Schema Information
#
# Table name: listens
#
#  id             :integer          not null, primary key
#  city           :string(255)
#  country        :string(255)
#  ip             :string(255)
#  source         :string(255)
#  user_agent     :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  asset_id       :integer
#  listener_id    :integer
#  track_owner_id :integer
#
# Indexes
#
#  index_listens_on_asset_id                       (asset_id)
#  index_listens_on_created_at                     (created_at)
#  index_listens_on_listener_id                    (listener_id)
#  index_listens_on_track_owner_id                 (track_owner_id)
#  index_listens_on_track_owner_id_and_created_at  (track_owner_id,created_at)
#
