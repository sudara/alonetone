class SetPositionToReflectDate < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |user|
      if user.playlists.size > 0
        user.playlists.find(:all, :order => 'created_at ASC').each do |playlist|
          playlist.insert_at
        end
      end
    end
  end

  def self.down
  end
end
