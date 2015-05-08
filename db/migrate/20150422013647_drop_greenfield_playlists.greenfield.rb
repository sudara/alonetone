# This migration comes from greenfield (originally 20150422013425)
class DropGreenfieldPlaylists < ActiveRecord::Migration
  def change
    drop_table :greenfield_playlist_tracks
    drop_table :greenfield_playlists
  end
end
