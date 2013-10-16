class ChangeSettingsFromStringToText < ActiveRecord::Migration
  def self.up
    remove_column :users, :settings
    add_column :users, :settings, :text
  end

  def self.down
  end
end
