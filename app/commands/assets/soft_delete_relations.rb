module Assets
  class SoftDeleteRelations
    attr_reader :asset

    def initialize(asset:)
      @asset = asset
    end

    def call
      time = Time.now
      # first update playlists
      asset.playlists.update_all(['tracks_count = tracks_count - 1, playlists.updated_at = ?', Time.now]) unless asset.playlists.empty?
      asset.comments.update_all(deleted_at: time)
      asset.tracks.update_all(deleted_at: time)
      asset.listens.update_all(deleted_at: time)
    end
  end
end
