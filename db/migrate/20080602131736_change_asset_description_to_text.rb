class ChangeAssetDescriptionToText < ActiveRecord::Migration
  def self.up
    change_column :assets, :description, :text
    add_column :assets, :lyrics, :text
  end

  def self.down
  end
end
