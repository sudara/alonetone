class AddIsSpamToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_spam, :boolean, default: false
  end
end
