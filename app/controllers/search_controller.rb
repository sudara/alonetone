class SearchController < ApplicationController
  before_filter :deliver_results
  
  def index
    respond_to do |wants| 
      wants.html
      wants.js
    end
  end
  
  protected
  
  def deliver_results
    if params[:query]
      @query = session[:last_search] = params[:query]
      @users = User.conditions_by_like(@query).includes(:pic).paginate(:per_page => 15, :page => params[:page])
      @assets = Asset.conditions_by_like(@query).includes(:user => :pic).paginate(:per_page => 15, :page => params[:page])
      @page_title = "#{(@query)} songs and #{@query} artists"
    else
      @page_title = "Search artists and uploads"
      flash[:error] = 'Please enter an artist name, a song name, or something to search for'
    end
  rescue       
  end
end
