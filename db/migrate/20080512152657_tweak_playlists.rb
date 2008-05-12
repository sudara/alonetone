class TweakPlaylists < ActiveRecord::Migration
  def self.up
    Playlist.find_all_by_description('').each do |playlist|
      playlist.description = playlist.title
      playlist.save
    end
    
    Playlist.find_all_by_private(nil).each do |playlist|
      playlist.private = false
      playlist.save
    end
  end

  def self.down
  end
end
