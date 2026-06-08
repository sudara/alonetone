class AddDeletedAtCreatedAtIndexesForAdminDashboard < ActiveRecord::Migration[8.1]
  def change
    add_index :users, [:deleted_at, :created_at]
    add_index :assets, [:deleted_at, :created_at]
    add_index :comments, [:deleted_at, :created_at]
  end
end
