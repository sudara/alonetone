module Greenfield
  class ApplicationController < ActionController::Base
    include AuthlogicHelpers
    helper_method :current_user

    def nothing
      render nothing: true
    end

    def require_login(login=nil)
      @user_session = UserSession.new(login: login.try(:login))
      render 'greenfield/application/require_login'
    end

    def login
      @user_session = UserSession.new(params[:user_session].merge(remember_me: true))
      if @user_session.save
        redirect_to params[:continue]
      else
        flash[:message] = nil
        render action: :require_login
      end
    end
    
    protected
    
    def find_asset_from_playlist
      @alonetone_playlist = ::Playlist.find_by!(permalink: params[:playlist_id])
      @playlist ||= Greenfield::Playlist.new(@alonetone_playlist)
      if params[:asset_id].present?
        @asset ||= Asset.where(id: @playlist.tracks.pluck(:asset_id), permalink: params[:asset_id]).take!
      end
    end
    
  end
end
