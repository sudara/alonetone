class MakePlaylistDescriptionsLonger < ActiveRecord::Migration
  def self.up
    change_column(:playlists, :description, :text)
  end

  def self.down
  end
end
