class AddPermalinks < ActiveRecord::Migration
  def self.up
    add_column :playlists, :permalink, :string
    add_column :assets, :permalink, :string
  
    add_index :assets, :permalink
    add_index :playlists, :permalink
  end

  def self.down
    remove_column :playlists, :permalink
    remove_column :assets, :permalink
  end
end
