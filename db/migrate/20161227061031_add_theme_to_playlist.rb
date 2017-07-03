class AddThemeToPlaylist < ActiveRecord::Migration[5.1]
  def change
    add_column :playlists, :theme, :string
  end
end
