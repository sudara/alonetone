module Assets
  class SoftDeleteRelations
    attr_reader :asset

    def initialize(asset:)
      @asset = asset
    end

    def call
      asset.comments&.map(&:soft_delete)
      # first update playlists
      asset.playlists.update_all(['tracks_count = tracks_count - 1, playlists.updated_at = ?', Time.now]) unless asset.playlists.empty?
      asset.tracks&.map(&:soft_delete)
      asset.listens&.map(&:soft_delete)
    end
  end
end
