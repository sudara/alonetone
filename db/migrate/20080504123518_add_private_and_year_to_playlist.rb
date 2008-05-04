class AddPrivateAndYearToPlaylist < ActiveRecord::Migration
  def self.up
    add_column :playlists, :year, :string
  end

  def self.down
    remove_column :playlists, :year
  end
end
