class RemoveForumCounters < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :posts_count
  end
end
