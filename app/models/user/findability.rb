class User
  def self.currently_online
     User.where(["last_request_at > ?", Time.now.utc - 15.minutes])
  end

  def self.conditions_by_like(value)
    conditions = ['users.display_name', 'users.login', 'profiles.bio', 'profiles.city', 'profiles.country'].collect do |c|
      "#{c} LIKE " + ActiveRecord::Base.connection.quote("%#{value}%")
    end
    where(conditions.join(" OR "))
  end

  def self.search(query, options = {})
    with_scope find: { conditions: build_search_conditions(query) } do
      find :all, options
    end
  end

  def self.build_search_conditions(query)
    query && ['LOWER(display_name) LIKE :q OR LOWER(login) LIKE :q', { q: "%#{query}%" }]
  end

  # feeds the users/index subnav
  def self.paginate_by_params(params)
    available_sortings = %w[last_uploaded most_listened_to new_artists monster_uploaders dedicated_listeners]
    params[:sort] = 'last_seen' if !params[:sort].present? || !available_sortings.include?(params[:sort])
    User.send(params[:sort])
  end

  protected

  # needed to map incoming params to scopes
  def self.last_seen
    recently_seen.limit(30)
  end

  def self.recently_joined
    activated.limit(30)
  end

  def self.new_artists
    musicians.reorder('users.created_at DESC').limit(30)
  end

  def self.most_listened_to
    result = Listen.since(1.month.ago).group(:track_owner).order('count_all DESC').limit(30).count
    result.collect(&:first)
  end

  def self.monster_uploaders
    musicians.reorder('users.assets_count DESC').limit(30)
  end

  def self.last_uploaded
    includes(:assets).order('assets.created_at DESC').limit(30)
  end

  def self.dedicated_listeners
    result = Listen.since(1.month.ago).where('listener_id is not null').group(:listener).order('count_all DESC').limit(30).count
    result.collect(&:first)
  end

  def geocode_address
    return unless city && country

    geo = GeoKit::Geocoders::MultiGeocoder.geocode([city, country].compact.join(', '))

    if geo.success
      self.lat = geo.lat
      self.lng = geo.lng
    end
  end
end
