class AddListensPerDayToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :listens_per_day, :float, :default => 0
    add_index 'assets', ['user_id','listens_per_day']
  end

  def self.down
    drop_column :assets, :listens_per_day
  end
end
