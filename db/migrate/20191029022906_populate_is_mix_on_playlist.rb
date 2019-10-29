class PopulateIsMixOnPlaylist < ActiveRecord::Migration[6.0]
  def change
    counter = 0
    Playlist.all.map do |playlist|
      playlist.set_mix_or_album

      counter += 1 if playlist.is_mix_changed?
    end
    Rails.logger.info "Changed #{counter} playlists"
  end
end
