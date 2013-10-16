class CreatePlaylists < ActiveRecord::Migration
  def self.up
    create_table :playlists do |t|
      t.string  :title
      t.string  :description
      t.string  :image
      t.integer :user_id
      t.integer :tracks_count, :default => 0

      t.timestamps 
    end
    
    add_index :playlists, :user_id
    
    create_table :tracks do |t|
      t.integer :playlist_id
      t.integer :asset_id
      t.integer :position
      
      t.timestamps
    end
    
    add_index :tracks, :playlist_id
    add_index :tracks, :asset_id
    add_index :assets, :user_id
  end

  def self.down
    drop_table :playlists
    drop_table :tracks
  end
end
