class CreateGreenfieldPlaylistDownloads < ActiveRecord::Migration
  def change
    create_table :greenfield_playlist_downloads do |t|
      t.string :title, null: false
      t.integer :playlist_id, null: false
      t.string :s3_path, null: false
      t.attachment :attachment
    end
  end
end
