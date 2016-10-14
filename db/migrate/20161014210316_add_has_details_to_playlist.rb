class AddHasDetailsToPlaylist < ActiveRecord::Migration
  def change  
    add_column :playlists, :has_details, :boolean, default: false
  end
end
