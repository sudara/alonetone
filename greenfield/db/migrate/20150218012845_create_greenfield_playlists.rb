class CreateGreenfieldPlaylists < ActiveRecord::Migration
  def change
    create_table :greenfield_playlists do |t|
      t.string :title
      t.string :permalink
      t.integer :user_id

      t.timestamps
    end
  end
end
