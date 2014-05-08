class ChangePostSpamToIsSpam < ActiveRecord::Migration
  def change
    rename_column(:posts, :spam, :is_spam)
    add_index(:posts, :is_spam)
  end
end
