class AddFavCountToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :favorites_count, :integer, :default => 0
  end

  def self.down
    drop_column :assets, :favorites_count
  end
end
