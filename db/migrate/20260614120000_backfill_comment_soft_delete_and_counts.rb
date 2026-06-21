class BackfillCommentSoftDeleteAndCounts < ActiveRecord::Migration[8.1]
  def up
    now = Time.now
    Comment.with_deleted.where(is_spam: true, deleted_at: nil).in_batches do |batch|
      batch.update_all(deleted_at: now)
    end

    Comment.recompute_cached_counts!
  end

  def down; end
end
