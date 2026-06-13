class SoftDeleteLiveSpamUsers < ActiveRecord::Migration[8.1]
  def up
    User.with_deleted.where(is_spam: true, deleted_at: nil).find_each do |user|
      UserCommand.new(user).soft_delete_with_relations
    end
  end

  def down; end
end
