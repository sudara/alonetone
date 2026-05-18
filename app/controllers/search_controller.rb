class SearchController < ApplicationController
  before_action :deliver_results

  def index
    if request.post? && params[:query].present?
      redirect_to search_query_path(params[:query])
    elsif params[:query].present?
      @query = session[:last_search] = params[:query]
      @users = User.with_preloads.joins(:profile).conditions_by_like(@query).limit(15)
      @assets_pagy, @assets = pagy(Asset.published.conditions_by_like(@query), limit: 15)
      @page_title = "#{@query} songs and #{@query} artists"
    end
  end

  protected

  def deliver_results
    if params[:query]
      @query = session[:last_search] = params[:query]
      @users = User.with_preloads.joins(:profile).conditions_by_like(@query).limit(15)
      @assets_pagy, @assets = pagy(Asset.published.conditions_by_like(@query), limit: 15)
      @page_title = "#{@query} songs and #{@query} artists"
    else
      @page_title = "Search artists and uploads"
    end
  rescue StandardError
  end
end
