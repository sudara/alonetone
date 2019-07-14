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

      # remove asset's listens_count from user record
      # listens_count on user is marked_as readonly
      # new_count = asset.user.listens_count - asset.listens_count
      # asset.user.update_attribute(:listens_count, new_count)
      asset.listens&.map(&:soft_delete)
    end
  end
end
