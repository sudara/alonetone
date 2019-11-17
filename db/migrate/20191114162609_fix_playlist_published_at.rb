class FixPlaylistPublishedAt < ActiveRecord::Migration[6.0]
  def change
    # published_at wasn't being updated in the last while.
    # so find our published playlists and update the timestamp
    published = Playlist.where(published_at: nil, private: false).where('tracks_count > 1')
    puts "#{published.count} playlists did not have a published_at date"
    published.update_all('published_at=updated_at')
  end
end
