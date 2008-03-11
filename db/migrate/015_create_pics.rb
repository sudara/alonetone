class CreatePics < ActiveRecord::Migration
  def self.up
    create_table :pics do |t|
      t.integer :size
      t.string :content_type
      t.string :filename
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string :thumbnail

      t.timestamps
    end
    
    add_column :playlists, :pic_id, :integer
    add_column :users, :pic_id, :integer
  end

  def self.down
    drop_table :pics
  end
end
