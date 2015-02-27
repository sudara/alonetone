require_dependency "greenfield/application_controller"

module Greenfield
  class PlaylistsController < Greenfield::ApplicationController
    before_filter :check_user, :only => :create

    def index
      @user = current_user
      @playlists = @user.greenfield_playlists
      @playlist ||= Greenfield::Playlist.new.tap{ |p| p.user_id = @user.id }
      @page_title = "#{current_user.display_name}'s playlists"
    end

    def create
      @user = current_user
      @playlist = @user.greenfield_playlists.build(params[:playlist])

      if @playlist.save
        redirect_to edit_playlist_path(@playlist)
      else
        index
      end
    end

    def edit
      @user = current_user
      @playlist = current_user.greenfield_playlists.find_by(permalink: params[:id])
    end

    def create_post
      playlist = current_user.greenfield_playlists.find_by(permalink: params[:id])
      playlist.posts << current_user.greenfield_posts.find(params[:post_id])
      render :nothing => true
    end

    def destroy_post
      playlist = current_user.greenfield_playlists.find_by(permalink: params[:id])
      playlist.playlist_tracks.where(:post_id => params[:post_id]).destroy_all
      render :nothing => true
    end

    def replace_all_posts
      playlist = current_user.greenfield_playlists.find_by(permalink: params[:id])
      playlist.transaction do
        playlist.playlist_tracks.delete_all
        params[:post_ids].each do |post_id|
          playlist.posts << current_user.greenfield_posts.find(post_id)
        end
      end
      render :nothing => true
    end

    private

    def check_user
      unless current_user.id == params[:playlist].delete(:user_id).to_i
        render :status => 403
      end
    end
  end
end
