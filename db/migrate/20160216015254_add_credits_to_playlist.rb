class AddCreditsToPlaylist < ActiveRecord::Migration
  def change
    add_column :playlists, :credits, :text
  end
end
