class Addbettercommentsindex < ActiveRecord::Migration[5.2]
  def change
    remove_index :comments, :created_at
    remove_index :comments, :is_spam
    add_index :comments, [:commentable_type, :is_spam, :private]
  end
end
