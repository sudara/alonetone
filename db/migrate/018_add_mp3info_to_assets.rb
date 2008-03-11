class AddMp3infoToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :samplerate, :integer
    add_column :assets, :bitrate, :integer
    add_column :assets, :genre, :string
    add_column :assets, :artist, :string
    remove_column :assets, :thumbnail
    remove_column :assets, :width
    remove_column :assets, :height
  end

  def self.down
    remove_column :assets, :samplerate
    remove_column :assets, :bitrate
    remove_column :assets, :album
    remove_column :assets, :genre
  end
end
