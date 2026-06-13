class AddIndexToCommentsIsSpamUpdatedAt < ActiveRecord::Migration[8.1]
  def change
    add_index :comments, %i[is_spam updated_at], algorithm: :inplace
  end
end
