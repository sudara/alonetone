class AddHotnessToTracks < ActiveRecord::Migration
  def self.up
    add_column :assets, :hotness, :float
  end

  def self.down
    remove_column :assets, :hotness
  end
end
