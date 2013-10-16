class CreateFeaturedTracks < ActiveRecord::Migration
  def self.up
    create_table :featured_tracks do |t|
      t.integer :position
      t.integer :feature_id
      t.integer :asset_id
      t.timestamps
    end
  end

  def self.down
    drop_table :featured_tracks
  end
end
