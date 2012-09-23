# -*- encoding : utf-8 -*-
class KillListensWithoutAsset < ActiveRecord::Migration
  def self.up
    # I forgot to tell listens to destroy themselves when the asset is deleted
    Listen.find(:all).select{|l| !l.asset}.each(&:destroy)
    
    # Let's kill playlists with no permalink too
    Playlist.find(:all).select{|p| !p.permalink}.each(&:destroy)
  end

  def self.down
  end
end
