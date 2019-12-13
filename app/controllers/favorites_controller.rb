# responsible for creating and deleting user's favorite tracks
# depends on asset_id
# user must be logged_in
# when favorite track is created it triggers favorites_count counter cache on asset
class FavoritesController < ApplicationController
  before_action :find_user
  before_action :find_asset
  before_action :require_login
  before_action :find_favorite_track, only: :delete

  def create
    raise ArgumentError unless @asset

    @user.tracks.create(asset_id: @asset.id, is_favorite: true)
    head :ok
  end

  def delete
    @favorite_track.destroy
    head :ok
  end

  private

  def find_user
    @user = current_user
  end

  def find_favorite_track
    @favorite_track = @user.tracks.favorites.where(asset_id: @asset.id).first
  end

  def find_asset
    @asset = Asset.find_by_id(params[:asset_id])
  end
end
