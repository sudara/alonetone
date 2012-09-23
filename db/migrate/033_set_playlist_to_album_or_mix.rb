# -*- encoding : utf-8 -*-
class SetPlaylistToAlbumOrMix < ActiveRecord::Migration
  def self.up
    # if any tracks in the playlist are not from the user, it is a mix
    Playlist.find(:all).each do |playlist|
      playlist.update_attribute(:is_mix, nil)
    end
  end

  def self.down
  end
end
