class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table "posts", :force => true do |t|
      t.integer  "user_id"
      t.integer  "topic_id"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "forum_id"
      t.text     "body_html"
    end
    add_column :users,  "posts_count", :integer, :default => 0
    add_column :users,  :moderator, :boolean, :default => false
  end

  def self.down
    drop_table :posts
    remove_column :users, :posts_count
    remove_column :users, :moderator
  end
end
