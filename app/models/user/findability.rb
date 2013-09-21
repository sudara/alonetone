# -*- encoding : utf-8 -*-
class User
    
  def self.currently_online
     User.where(["last_login_at > ?", Time.now.utc-15.minutes])
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
    subnav = %w(recently_joined monster_uploaders on_twitter dedicated_listeners last_uploaded)
    params[:sort] = 'last_seen' if !params[:sort].present or !subnav.include?(params[:sort])
    User.send(params[:sort]).page(:page, :per_page => 15)
  end

  protected
  

  # needed to map incoming params to scopes
  def self.last_seen recently_seen; end
  def self.recently_joined activated; end
  def self.monster_uploaders musicians; end
  
  def last_uploaded
    @entries = WillPaginate::Collection.create((params[:page] || 1), 15) do |pager|
      distinct_users = Asset.select(:user_id).uniq.includes(:user => :pic).order('assets.created_at DESC').limit(pager.per_page).offset(pager.offset)

          
      pager.replace(distinct_users.collect(&:user)) # only send back the users
    
      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = User.musicians.count(:all, :conditions => 'assets_count > 0')
      end  
    end
    @entries
  end
  
  def dedicated_listeners
    @entries = WillPaginate::Collection.create((params[:page] || 1), 15) do |pager|
      # returns an array, like so: [User, number_of_listens]
      result = Listen.count(:order      => 'count_all DESC',
        :conditions => 'listener_id != ""',
        :group      => :listener,
        :limit      => pager.per_page,
        :offset     => pager.offset
      )

      # inject the result array into the paginated collection:
      pager.replace(result.collect(&:first))

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = Listen.count(:listener_id, :conditions => 'listens.listener_id != ""')
      end
      @enries
    end
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
