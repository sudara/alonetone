class AddIndexesToComments < ActiveRecord::Migration
  def self.up
    add_index :comments, [:commentable_id, :commentable_type]
    add_index :comments, :spam
    add_index :comments, :created_at
    add_index :pics, [:picable_id, :picable_type]
    remove_column :comments, :is_spam
  end

  def self.down
  end
end
