class AddDeletedAtToAssets < ActiveRecord::Migration[5.2]
  def change
    add_column :assets, :deleted_at, :datetime
    add_index :assets, :deleted_at
  end
end
