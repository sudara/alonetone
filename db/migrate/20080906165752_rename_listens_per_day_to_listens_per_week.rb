class RenameListensPerDayToListensPerWeek < ActiveRecord::Migration
  def self.up
    rename_column(:assets, :listens_per_day, :listens_per_week)
  end
  def self.down
  end
end
