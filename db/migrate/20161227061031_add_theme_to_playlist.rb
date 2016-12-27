class AddThemeToPlaylist < ActiveRecord::Migration
  def change
    add_column :playlists, :theme, :string
  end
end
