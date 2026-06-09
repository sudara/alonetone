class AddCompositeListenIndexesForAdminStats < ActiveRecord::Migration[8.1]
  def change
    # Covers the admin GROUP BY ip / asset_id aggregates: equality on deleted_at
    # (SoftDeletion default scope), range on created_at, group column read from the index.
    add_index :listens, [:deleted_at, :created_at, :ip], algorithm: :inplace
    add_index :listens, [:deleted_at, :created_at, :asset_id], algorithm: :inplace
  end
end
