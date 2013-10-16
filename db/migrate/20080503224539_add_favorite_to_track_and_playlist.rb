class AddFavoriteToTrackAndPlaylist < ActiveRecord::Migration
  def self.up
    add_column :tracks, :is_favorite, :boolean, :default => false
    add_column :playlists, :is_favorite, :boolean, :default => false
  end

  def self.down
    remove_column :tracks, :is_favorite
    remove_column :playlists, :is_favorite
  end
end
