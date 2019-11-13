class PopulateIsMixOnPlaylist < ActiveRecord::Migration[6.0]
  def change
    counter = 0
    Playlist.all.map do |playlist|
      playlist.is_mix = true if playlist.consider_a_mix?

      counter += 1 if playlist.is_mix_changed?
    end
    Rails.logger.info "Changed #{counter} playlists"
  end
end
