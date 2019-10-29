class PopulatePublishedAtToPlaylists < ActiveRecord::Migration[6.0]
  def change
    Playlist.find_each do |playlist|
      next if playlist.published_at
      next unless playlist.private == false
      next unless playlist.can_be_public?
      playlist.published_at = playlist.updated_at
    end
  end
end
