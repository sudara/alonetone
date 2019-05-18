class AddCoverQualityToPlaylists < ActiveRecord::Migration[5.2]
  def change
    add_column :playlists, :cover_quality, :integer, default: 2
  end
end
