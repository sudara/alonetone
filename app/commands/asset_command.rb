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
    asset.comments.update_all(deleted_at: time)
    asset.tracks.update_all(deleted_at: time)
    asset.listens.update_all(deleted_at: time)
    asset.soft_delete
  end

  def restore_with_relations
    asset.restore
    asset.playlists.update_all(['tracks_count = tracks_count + 1, playlists.updated_at = ?', Time.now]) unless asset.playlists.empty?
    asset.comments.update_all(deleted_at: nil)
    asset.tracks.update_all(deleted_at: nil)
    asset.listens.update_all(deleted_at: nil)
  end

  def destroy_with_relations
    asset.comments&.with_deleted&.delete_all
    asset.tracks&.with_deleted&.delete_all
    asset.listens&.with_deleted&.delete_all
    asset.audio_feature.delete
    asset.destroy
  end
end