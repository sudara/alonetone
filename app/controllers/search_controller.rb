class SearchController < ApplicationController
  before_action :deliver_results

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
      @users = User.joins(:profile).conditions_by_like(@query).includes(:pic).limit(15)
      # need to pass additional param query
      # for pagy to only paginate via matched query
      @assets_pagy, @assets = pagy(Asset.published.conditions_by_like(@query), items: 15, params: { query: @query })
      @page_title = "#{@query} songs and #{@query} artists"
    else
      @page_title = "Search artists and uploads"
      flash[:error] = 'Please enter an artist name, a song name, or something to search for'
    end
  rescue StandardError
  end
end
