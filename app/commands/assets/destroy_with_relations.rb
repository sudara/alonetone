module Assets
  class DestroyWithRelations
    attr_reader :asset

    def initialize(asset:)
      @asset = asset
    end

    def execute
      asset.comments&.with_deleted&.delete_all
      asset.tracks&.with_deleted&.delete_all
      asset.listens&.with_deleted&.delete_all
      asset.audio_feature.delete
      asset.destroy
    end
  end
end
