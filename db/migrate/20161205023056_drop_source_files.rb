class DropSourceFiles < ActiveRecord::Migration[5.0]
  def change
    drop_table :source_files
    remove_column :users, :plus_enabled
  end
end
