module Greenfield
  class ApplicationController < ActionController::Base
    include AuthlogicHelpers
    helper ::PlaylistsHelper
    helper_method :current_user

    def nothing
      render nothing: true
    end

    def require_login(login = nil)
      @user_session = UserSession.new(login: login.try(:login))
      render 'greenfield/application/require_login'
    end

    def login
      @user_session = UserSession.new(user_session_params.merge(remember_me: true))
      if @user_session.save
        redirect_to params[:continue]
      else
        flash[:message] = nil
        render action: :require_login
      end
    end

    protected

    def user_session_params
      params.require(:user_session).permit(:password, :login)
    end

    def find_asset_from_playlist
      alonetone_playlist = ::Playlist.find_by!(permalink: params[:playlist_id])
      @playlist ||= Greenfield::Playlist.new(alonetone_playlist)
      @asset ||= Asset.where(id: @playlist.tracks.pluck(:asset_id), permalink: params[:asset_id]).take! if params[:asset_id].present?
    end
  end
end
