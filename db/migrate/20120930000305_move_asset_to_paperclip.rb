class MoveAssetToPaperclip < ActiveRecord::Migration
  def up
    # The old schema....
    
    # t.string   "content_type"
    # t.string   "filename"
    # t.integer  "size"
    # t.integer  "parent_id"
    # t.integer  "site_id"
    # t.datetime "created_at"
    # t.string   "title"
    # t.integer  "thumbnails_count", :default => 0
    # t.integer  "user_id"
    # t.integer  "length"
    # t.string   "album"
    # t.string   "permalink"
    # t.integer  "samplerate"
    # t.integer  "bitrate"
    # t.string   "genre"
    # t.string   "artist"
    # t.integer  "listens_count",    :default => 0
    # t.text     "description"
    # t.text     "credits"
    # t.string   "youtube_embed"
    # t.boolean  "private"
    # t.float    "hotness"
    # t.integer  "favorites_count",  :default => 0
    # t.text     "lyrics"
    # t.text     "description_html"
    # t.float    "listens_per_week"
    # t.integer  "comments_count",   :default => 0
    # t.datetime "updated_at"
    
    
    # make us paperclip frindely
    rename_column :assets, :size, :mp3_file_size
    rename_column :assets, :content_type, :mp3_content_type
    rename_column :assets, :filename, :mp3_file_name

    # ==  MoveAssetToPaperclip: migrating ===========================================
    # -- rename_column(:assets, :size, :mp3_file_size)
    #    -> 3.3117s
    # -- rename_column(:assets, :content_type, :mp3_content_type)
    #    -> 2.3843s
    # -- rename_column(:assets, :filename, :mp3_file_name)
    #    -> 2.3997s
    # ==  MoveAssetToPaperclip: migrated (8.0961s) ==================================

  end

  def down
  end
end
