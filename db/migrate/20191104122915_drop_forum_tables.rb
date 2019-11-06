class DropForumTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :forums
    drop_table :posts
    drop_table :topics
  end
end
