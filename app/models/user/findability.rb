class User
    
  def self.currently_online
     User.where(["last_request_at > ?", Time.now.utc-15.minutes])
  end
  
  def self.conditions_by_like(value) 
    conditions = ['users.display_name','users.login','users.bio','users.city','users.country'].collect do |c|
      "#{c} LIKE " + ActiveRecord::Base.connection.quote("%#{value}%") 
    end
    where(conditions.join(" OR "))
  end
  
  def self.search(query, options = {})
    with_scope :find => { :conditions => build_search_conditions(query) } do
      find :all, options
    end
  end
  
  def self.build_search_conditions(query)
    query && ['LOWER(display_name) LIKE :q OR LOWER(login) LIKE :q', {:q => "%#{query}%"}]
  end
  
  # feeds the users/index subnav
  def self.paginate_by_params(params)
    if params[:sort] == 'dedicated_listeners'
      User.dedicated_listeners(params[:page] || 1, params[:per_page] || 15)
    else
      subnav = %w(recently_joined monster_uploaders on_twitter last_uploaded)
      params[:sort] = 'last_seen' if !params[:sort].present? or !subnav.include?(params[:sort])
      User.send(params[:sort]).paginate(:page => params[:page], :per_page => 15)
    end
  end

  protected
  

  # needed to map incoming params to scopes
  def self.last_seen 
    recently_seen
  end
  
  def self.recently_joined 
    activated
  end
  
  def self.monster_uploaders 
    musicians
  end
  
  def self.last_uploaded
    includes(:assets).order('assets.created_at DESC')
  end
  
  def self.dedicated_listeners(page, per_page)
   entries = WillPaginate::Collection.create(page, per_page) do |pager|
      # returns an array, like so: [User, number_of_listens]
      result = Listen.since(1.month.ago).where('listener_id is not null').group(:listener).order('count_all DESC').limit(pager.per_page).offset(pager.offset).count

      # inject the result array into the paginated collection:
      pager.replace(result.collect(&:first))

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = Listen.where('listener_id != ""').count(:listener_id)
      end
    end
    entries
  end
  
  def geocode_address
    return unless city && country
    geo=GeoKit::Geocoders::MultiGeocoder.geocode([city, country].compact.join(', '))

    if geo.success
      self.lat = geo.lat
      self.lng = geo.lng
    end
  end
end
