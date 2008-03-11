class LoggedExceptionsController < ActionController::Base
  cattr_accessor :application_name
  layout nil

  def index
    @exception_names    = LoggedException.find_exception_class_names
    @controller_actions = LoggedException.find_exception_controllers_and_actions
    query
  end

  def query
    conditions = []
    parameters = []
    unless params[:id].blank?
      conditions << 'id = ?'
      parameters << params[:id]
    end
    unless params[:query].blank?
      conditions << 'message LIKE ?'
      parameters << "%#{params[:query]}%"
    end
    unless params[:date_ranges_filter].blank?
      conditions << 'created_at >= ?'
      parameters << params[:date_ranges_filter].to_f.days.ago.utc
    end
    unless params[:exception_names_filter].blank?
      conditions << 'exception_class = ?'
      parameters << params[:exception_names_filter]
    end
    unless params[:controller_actions_filter].blank?
      conditions << 'controller_name = ? AND action_name = ?'
      parameters += params[:controller_actions_filter].split('/').collect(&:downcase)
    end
    @exceptions = LoggedException.paginate :order => 'created_at desc', :page => params[:page], :per_page => 30, 
        :conditions => conditions.empty? ? nil : parameters.unshift(conditions * ' and ')

    
    respond_to do |format|
      format.html { redirect_to :action => 'index' unless action_name == 'index' }
      format.js   { render :action => 'query.rjs'  }
      format.rss  { render :action => 'query.rxml' }
    end
  end
  
  def show
    @exc = LoggedException.find params[:id]
    respond_to do |format|
      format.js
    end
  end
  
  def destroy
    LoggedException.destroy params[:id]
  end
  
  def destroy_all
    LoggedException.delete_all ['id in (?)', params[:ids]] unless params[:ids].blank?
    query
  end

  private
    def access_denied_with_basic_auth
      headers["Status"]           = "Unauthorized"
      headers["WWW-Authenticate"] = %(Basic realm="Web Password")
      render :text => "Could't authenticate you", :status => '401 Unauthorized'
    end

    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end
end