class Listen < ActiveRecord::Base
  include SoftDeletion

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

  def self.monthly_listen_count_for(date = Time.now)
    # returns [count, year_month_label]
    [Listen.where('created_at > ? AND created_at < ?',
      date.beginning_of_month, date.end_of_month).count,
      date.strftime('%b %y').to_s]
  end

  protected

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
#  deleted_at     :datetime
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
#  index_listens_on_asset_id                                (asset_id)
#  index_listens_on_created_at                              (created_at)
#  index_listens_on_deleted_at_and_created_at_and_asset_id  (deleted_at,created_at,asset_id)
#  index_listens_on_deleted_at_and_created_at_and_ip        (deleted_at,created_at,ip)
#  index_listens_on_ip                                      (ip)
#  index_listens_on_listener_id                             (listener_id)
#  index_listens_on_track_owner_id                          (track_owner_id)
#  index_listens_on_track_owner_id_and_created_at           (track_owner_id,created_at)
#
