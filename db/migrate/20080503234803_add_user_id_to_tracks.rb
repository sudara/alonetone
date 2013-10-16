class AddUserIdToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :user_id, :integer
    add_index :tracks, :user_id
  end

  def self.down
  end
end
