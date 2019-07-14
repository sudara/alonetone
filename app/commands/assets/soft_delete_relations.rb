module Assets
  class SoftDeleteRelations
    attr_reader :asset

    def initialize(asset:)
      @asset = asset
    end

    def call
      asset.comments&.map(&:soft_delete)
      # first update playlists
      unless asset.playlists.empty?
        asset.playlists.update_all(['tracks_count = tracks_count - 1, playlists.updated_at = ?', Time.now])
      end
      asset.tracks&.map(&:soft_delete)
      asset.listens&.map(&:soft_delete)
    end
  end
end
