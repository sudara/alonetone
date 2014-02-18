class ChartsController < ApplicationController

  def song_plays
    render :json => Asset.group(:listens_count).sum(:listens_count), height: '200px'
  end
  
end