# handle logic related to asset and its relations
class AssetCommand
  attr_reader :asset

  def initialize(asset)
    @asset = asset
  end

  def soft_delete_with_relations
    time = Time.now
    # first update playlists
    asset.playlists.update_all(['tracks_count = tracks_count - 1, playlists.updated_at = ?', Time.now]) unless asset.playlists.empty?
    Comment.adjust_cached_comment_counts(asset.comments, -1)
    asset.comments.update_all(deleted_at: time)
    asset.tracks.update_all(deleted_at: time)
    asset.listens.update_all(deleted_at: time)
    asset.soft_delete
    asset.user.decrement!(:assets_count, touch: true)
    asset.user.refresh_last_uploaded_at!
  end

  def restore_with_relations
    return unspam_and_restore_with_relations if asset.is_spam?

    asset.restore
    asset.user.increment!(:assets_count, touch: true)
    asset.user.refresh_last_uploaded_at!
    asset.playlists.with_deleted.update_all(['tracks_count = tracks_count + 1, playlists.updated_at = ?', Time.now]) unless asset.playlists.with_deleted.empty?
    Comment.adjust_cached_comment_counts(asset.comments.with_deleted, 1)
    asset.comments.with_deleted.update_all(deleted_at: nil)
    asset.tracks.with_deleted.update_all(deleted_at: nil)
    asset.listens.with_deleted.update_all(deleted_at: nil)
  end

  def destroy_with_relations
    Asset.transaction do
      decrement_listen_counters
      asset.comments&.with_deleted&.delete_all
      asset.tracks&.with_deleted&.delete_all
      asset.listens&.with_deleted&.delete_all
      asset.audio_feature&.destroy!
      asset.destroy!
    end
  end

  def spam_and_soft_delete_with_relations
    asset.spam!
    mark_spam_and_soft_delete
  end

  def mark_spam_and_soft_delete
    asset.update_attribute :is_spam, true
    soft_delete_with_relations
  end

  def unspam_and_restore_with_relations
    asset.ham!
    asset.update_attribute :is_spam, false
    restore_with_relations
  end

  private

  def decrement_listen_counters
    Listen.decrement_counter_caches(
      owner_counts: asset.listens.with_deleted.group(:track_owner_id).count
    )
  end
end
