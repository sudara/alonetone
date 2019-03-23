class DeletedUserCleanupJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.with_deleted.find_by(id: user_id)
    return unless user&.deleted?

    user.destroy!
  end
end
