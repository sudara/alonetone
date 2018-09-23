class AddId3TrackNumToAsset < ActiveRecord::Migration[5.2]
  def change
    add_column :assets, :id3_track_num, :integer, default: 1
  end
end
