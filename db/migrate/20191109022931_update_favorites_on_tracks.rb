class UpdateFavoritesOnTracks < ActiveRecord::Migration[6.0]
  def change
    asset_ids = Track.favorites.map(&:asset_id).uniq
    puts "Found #{asset_ids.length} favorite assets."

    Asset.where(id: asset_ids).find_each do |asset|
      if asset.favorites_count != asset.tracks.favorites.count
        asset.favorites_count = asset.tracks.favorites.count
      end
    end
  end
end
