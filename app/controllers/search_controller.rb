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
    @users = User.paginate(:all, :conditions => User.conditions_by_like(params[:search][:query],'users.display_name','users.login'), :include => :pic, :per_page => 15, :page => params[:page])
    @assets = Asset.paginate(:all, :conditions => Asset.conditions_by_like(params[:search][:query], 'assets.title', 'assets.description'), :include => [:user => :pic], :per_page => 15, :page => params[:page])
  rescue ActiveRecord::RecordNotFound
  end
end