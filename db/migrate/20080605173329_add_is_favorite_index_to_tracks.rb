class AddIsFavoriteIndexToTracks < ActiveRecord::Migration
  def self.up
    add_index :tracks, :is_favorite
  end

  def self.down
  end
end
