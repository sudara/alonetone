class SearchController < ApplicationController
  before_filter :deliver_results
  
  def index
    respond_to do |wants| 
      wants.html do
        
      end
      wants.js do
        
      end
    end
  end
  
  protected
  
  def deliver_results
    @query = params[:search][:query]
    @users = User.paginate(:all, :conditions => User.conditions_by_like(@query,'users.display_name','users.login','users.bio'), :include => :pic, :per_page => 15, :page => params[:page])
    @assets = Asset.paginate(:all, :conditions => Asset.conditions_by_like(@query, 'assets.title', 'assets.description'), :include => [:user => :pic], :per_page => 15, :page => params[:page])
  rescue ActiveRecord::RecordNotFound
  end
end