class ListensController < ApplicationController
  
  before_filter :find_user
  before_filter :find_listen_history
  
  def index
    
  end
  
  protected
  
  def find_listen_history
    @listens = @user.listens.paginate( 
      :per_page => 10, 
      :page     => params[:listens_page]
    )
    @track_plays = @user.track_plays.paginate(
      :per_page => 10, 
      :page     => params[:track_plays_page]
    )
  end
  
end
