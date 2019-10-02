class RemovePaperclipForeignKeyColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :playlists, :pic_id, :integer
  end
end
