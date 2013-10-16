class CreateSourceFiles < ActiveRecord::Migration
  def self.up
    create_table :source_files do |t|
      t.string   "content_type"
      t.string   "filename"
      t.integer  "size",             :limit => 11
      t.integer  "user_id"
      t.integer  "downloads_count", :default => 0
      t.timestamps
    end
    add_column :users, :plus_enabled, :boolean, :default => false
  end

  def self.down
    drop_table :source_files
  end
end
