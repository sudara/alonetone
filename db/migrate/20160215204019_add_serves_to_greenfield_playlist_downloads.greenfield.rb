# This migration comes from greenfield (originally 20160215203822)
class AddServesToGreenfieldPlaylistDownloads < ActiveRecord::Migration
  def change
    add_column :greenfield_playlist_downloads, :serves, :integer, null: false, default: 0
    execute "UPDATE greenfield_playlist_downloads SET serves = 0"
  end
end
