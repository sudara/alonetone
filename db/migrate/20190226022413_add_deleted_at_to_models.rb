class AddDeletedAtToModels < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :deleted_at, :datetime
    add_column :assets, :deleted_at, :datetime
    add_column :tracks, :deleted_at, :datetime
    add_column :playlists, :deleted_at, :datetime
    add_column :listens, :deleted_at, :datetime
    add_column :comments, :deleted_at, :datetime
    add_column :posts, :deleted_at, :datetime
  end
end
