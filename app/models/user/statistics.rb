class User
  def self.calculate_bandwidth_used
    User.select(:id, :created_at).find_each(batch_size: 500) do |u|
      User.where(id: u.id).update_all(bandwidth_used: u.calculate_bandwidth_used)
    end
  end

  def number_of_tracks_listened_to
    Listen.count(:all,
      order: 'count_all DESC',
      conditions: { listener_id: self })
  end

  def mostly_listens_to
    User.where(id: most_listened_to_user_ids(10)).includes(:pic)
  end

  def calculate_bandwidth_used
    assets.sum(&:bandwidth_used).ceil # in gb
  end

  def total_bandwidth_cost
    # s3 is 12 cents a gig
    ActionController::Base.helpers.number_to_currency((bandwidth_used * 0.12), unit: '$')
  end

  def most_listened_to_user_ids(limit = 10)
    listens
      .where(['track_owner_id != ? AND DATE(`listens`.created_at) > DATE_SUB( CURDATE(), interval 4 month)', id])
      .distinct(:track_owner_id)
      .group(:track_owner_id)
      .limit(limit)
      .order('count_track_owner_id DESC')
      .count(:track_owner_id).collect(&:first)
  end

  def plays_since_last_session
    track_plays.between(last_session_at, Time.now.utc).count
  end

  def comments_since_last_session
    comments.between(last_session_at, Time.now.utc).count
  end

  def self.with_same_ip
    User.order('count_all DESC').group(:last_login_ip).where('last_login_ip is not NULL').limit(25).count
  end
end
