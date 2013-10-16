class AddPositionToPlaylists < ActiveRecord::Migration
  def self.up
    add_column :playlists, :position, :integer
    add_index :playlists, :position
  end

  def self.down
    drop_column :playlits, :position
  end
end
