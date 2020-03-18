class RenamePrivateToPublished < ActiveRecord::Migration[6.0]
  def change
    rename_column :playlists, :private, :published
    puts "flipping dat boolean"
    Playlist.with_deleted.find_each do |p|
      p.update_column :published, !p.published
    end
    change_column_default :playlists, :published, false
  end
end
