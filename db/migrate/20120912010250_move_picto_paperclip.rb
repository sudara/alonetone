class MovePictoPaperclip < ActiveRecord::Migration
  def up
    # before
    # t.integer  "size"
    # t.string   "content_type"
    # t.string   "filename"
    # t.integer  "height"
    # t.integer  "width"
    # t.integer  "parent_id"
    # t.string   "thumbnail"
    # t.datetime "created_at"
    # t.datetime "updated_at"
    # t.string   "picable_type"
    # t.integer  "picable_id"
    
    # make us paperclip frindely
    rename_column :pics, :size, :pic_file_size
    rename_column :pics, :content_type, :pic_content_type
    rename_column :pics, :filename, :pic_file_name
    
    # unnecessary columns
    remove_column :pics, :thumbnail
    remove_column :pics, :height
    remove_column :pics, :width
    
    # no longer need db records of each thumbnail!
    num = Pic.where('parent_id is not ?', nil).delete_all
    puts "Migrated Pics to Paperclip"
    puts "----#{num} rows of pointless old picture data have been removed. Yay! "
  end

  def down
  end
end
