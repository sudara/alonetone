class UserCommand
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def soft_delete_with_relations
    efficiently_delete_relations
    user.soft_delete
  end

  def restore_with_relations
    return unspam_and_restore_with_relations if user.is_spam?

    efficiently_restore_relations
    user.restore
  end

  def destroy_with_relations
    efficiently_destroy_relations
  end

  def spam_soft_delete_with_relations
    user.spam!
    user.update_attribute :is_spam, true
    soft_delete_with_relations
  end

  def unspam_and_restore_with_relations
    user.ham!
    user.update_attribute :is_spam, false
    restore_with_relations
  end

  private

  def efficiently_delete_relations(time = Time.now)
    Comment.adjust_cached_comment_counts(comments_touching_user, -1)
    Listen.where(track_owner_id: user.id).update_all(deleted_at: time)
    Listen.where(listener_id: user.id).update_all(deleted_at: time)
    Playlist.joins(:assets).where(assets: { user_id: user.id })
      .update_all(['tracks_count = tracks_count - 1, playlists.updated_at = ?', time])
    Track.joins(:asset).where(assets: { user_id: user.id }).update_all(deleted_at: time)
    user.assets.update_all(deleted_at: time)

    # comments given
    user.comments_made.update_all(deleted_at: time)
    # comments received
    %w[tracks playlists comments_received comments_made].each do |user_relation|
      user.send(user_relation).update_all(deleted_at: time)
    end
    # comments by others on user's assets
    # are deleted as part of asset has_many comments dependant: destroy
  end

  def efficiently_restore_relations
    Asset.with_deleted.where(user_id: user.id).update_all(deleted_at: nil)
    Listen.with_deleted.where(track_owner_id: user.id).update_all(deleted_at: nil)
    Listen.with_deleted.where(listener_id: user.id).update_all(deleted_at: nil)
    Playlist.with_deleted.joins(:assets).where(assets: { user_id: user.id })
      .update_all(['tracks_count = tracks_count - 1, playlists.updated_at = ?', Time.now])
    Track.with_deleted.joins(:asset).where(assets: { user_id: user.id }).update_all(deleted_at: nil)
    Track.with_deleted.where(user_id: user.id).update_all(deleted_at: nil)
    Playlist.with_deleted.where(user_id: user.id).update_all(deleted_at: nil)

    Comment.adjust_cached_comment_counts(comments_touching_user.with_deleted, 1)
    Comment.with_deleted.where(commenter_id: user.id).update_all(deleted_at: nil)
    Comment.with_deleted.where(user_id: user.id).update_all(deleted_at: nil)
  end

  def comments_touching_user
    Comment.where('comments.commenter_id = :id OR comments.user_id = :id', id: user.id)
  end

  # with_deleted everywhere: by the time a user is perma-deleted, the soft-delete
  # cascade has already hidden all their relations from the default scope.
  def efficiently_destroy_relations
    Listen.transaction do
      Listen.with_deleted.where(track_owner_id: user.id).delete_all
      purge_listens_to_surviving_tracks
    end
    # other users' playlist tracks_counts were already decremented when the user was soft-deleted
    Track.with_deleted.joins('INNER JOIN assets ON assets.id = tracks.asset_id')
      .where(assets: { user_id: user.id }).delete_all
    Asset.with_deleted.where(user_id: user.id).find_each { |asset| AssetCommand.new(asset).destroy_with_relations }

    %w[tracks playlists comments_received comments_made].each do |user_relation|
      user.send(user_relation).with_deleted.delete_all
    end
    true
  end

  def purge_listens_to_surviving_tracks
    scope = Listen.with_deleted
      .where(listener_id: user.id)
      .where('track_owner_id IS NULL OR track_owner_id != ?', user.id)

    Listen.decrement_counter_caches(
      asset_counts: scope.group(:asset_id).count,
      owner_counts: scope.group(:track_owner_id).count
    )
    scope.delete_all
  end
end
