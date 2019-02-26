class AddDeletedAtToModels < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :deleted_at, :datetime
    add_column :assets, :deleted_at, :datetime
    add_column :tracks, :deleted_at, :datetime
    add_column :playlists, :deleted_at, :datetime
    add_column :listens, :deleted_at, :datetime
    add_column :comments, :deleted_at, :datetime
    add_column :features, :deleted_at, :datetime
    add_column :topics, :deleted_at, :datetime

    add_index :assets, :deleted_at
    add_index :users, :deleted_at
    add_index :tracks, :deleted_at
    add_index :playlists, :deleted_at
    add_index :listens, :deleted_at
    add_index :comments, :deleted_at
    add_index :features, :deleted_at
    add_index :topics, :deleted_at
  end
end
