class DropPics < ActiveRecord::Migration[6.0]
  def change
    drop_table :pics do |t|
      t.integer :pic_file_size
      t.string :pic_content_type
      t.string :pic_file_name
      t.integer :parent_id
      t.string :picable_type
      t.integer :picable_id

      t.timestamps

      t.index [:picable_id, :picable_type]
    end
  end
end
