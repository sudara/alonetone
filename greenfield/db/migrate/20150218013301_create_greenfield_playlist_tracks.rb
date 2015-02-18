class CreateGreenfieldPlaylistTracks < ActiveRecord::Migration
  def change
    create_table :greenfield_playlist_tracks do |t|
      t.integer :playlist_id
      t.integer :post_id
      t.integer :position

      t.timestamps
    end
  end
end
