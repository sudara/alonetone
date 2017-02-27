class AddUpdatedAtIndexToAssets < ActiveRecord::Migration[5.1]
  def change
    add_index :assets, :updated_at
    add_index :users, :updated_at
  end
end
