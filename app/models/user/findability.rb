class User
  
  def self.currently_online
     User.find(:all, :conditions => ["last_seen_at > ?", Time.now-5.hours])
  end
  
  # Generates magic %LIKE% sql statements for all columns
  def self.conditions_by_like(value, *columns) 
    columns = self.content_columns if columns.size==0 
    columns = columns[0] if columns[0].kind_of?(Array) 
    conditions = columns.map {|c| 
    c = c.name if c.kind_of? ActiveRecord::ConnectionAdapters::Column 
    "#{c} LIKE " + ActiveRecord::Base.connection.quote("%#{value}%") 
    }.join(" OR ") 
  end
  
  def self.search(query, options = {})
    with_scope :find => { :conditions => build_search_conditions(query) } do
      find :all, options
    end
  end
  
  def self.build_search_conditions(query)
    query && ['LOWER(display_name) LIKE :q OR LOWER(login) LIKE :q', {:q => "%#{query}%"}]
  end
  
  def self.paginate_by_params(params)
    case params[:sort]
    when 'recently_joined' 
      self.activated.paginate(:all, :per_page => 15, :page => params[:page])
    when 'monster_uploaders'
      self.musicians.paginate(:all,:per_page => 15, :page => params[:page])
    when 'dedicated_listeners'
      @entries = WillPaginate::Collection.create((params[:page] || 1), 15) do |pager|
        # returns an array, like so: [User, number_of_listens]
        result = Listen.count(:all, :order => 'count_all DESC', :conditions => 'listener_id != ""', :group => :listener, :limit => pager.per_page, :offset => pager.offset)

        # inject the result array into the paginated collection:
        pager.replace(result)
        
        unless pager.total_entries
          # the pager didn't manage to guess the total count, do it manually
          pager.total_entries = Listen.count(:listener_id, :conditions => 'listens.listener_id != ""')
        end
      end
    when 'last_uploaded'
     @entries = WillPaginate::Collection.create((params[:page] || 1), 15) do |pager|
        distinct_users = Asset.find(:all, :select => 'DISTINCT user_id', :include => [:user => :pic], :order => 'assets.created_at DESC', :limit => pager.per_page, :offset => pager.offset)
              
        pager.replace(distinct_users.collect(&:user)) # only send back the users
        
        unless pager.total_entries
          # the pager didn't manage to guess the total count, do it manually
          pager.total_entries = User.musicians.count(:all, :conditions => 'assets_count > 0')
        end  
      end
    else # last_seen
      self.recently_seen.paginate(:all, :page => params[:page], :per_page => 15)
    end
  end
  protected
  def geocode_address
    return unless city && country
    geo=GeoKit::Geocoders::MultiGeocoder.geocode([city, country].compact.join(', '))
    self.lat, self.lng = geo.lat,geo.lng if geo.success
  end
end