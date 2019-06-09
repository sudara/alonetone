class MovePlaylistDescriptionToCredits < ActiveRecord::Migration[6.0]
  def change
    # Only playlist.credits shows in White Theme
    Playlist.find_each do |playlist|
      if playlist.description.present?
        if playlist.credits.present?
          playlist.update_column :credits, "#{playlist.description}\n#{playlist.credits}"
        else
          playlist.update_column :credits, playlist.description
        end
      end
    end

    remove_column :playlists, :description
  end
end
