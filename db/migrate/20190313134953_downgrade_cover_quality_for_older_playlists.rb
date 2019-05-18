class DowngradeCoverQualityForOlderPlaylists < ActiveRecord::Migration[5.2]
  def change
    Playlist.where(pic_id: 0..69807).update(cover_quality: :ancient)
    Playlist.where(pic_id: 69806..72848).update(cover_quality: :legacy)
  end
end
