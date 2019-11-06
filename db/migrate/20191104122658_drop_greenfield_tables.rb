class DropGreenfieldTables < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :greenfield_enabled
    drop_table :greenfield_attached_assets
    drop_table :greenfield_playlist_downloads
    drop_table :greenfield_posts
  end
end
