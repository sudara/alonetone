class ChangeDefaultListPositionTo1 < ActiveRecord::Migration
  def change
    list_models = [FeaturedTrack, Forum, Playlist,
                   Track, Greenfield::PlaylistTrack]

    list_models.each do |model|
      change_column model.table_name, :position, :integer, :default => 1
      model.where(:position => 0).ids.each do |id|
        model.update(id, :position => 1)
      end
    end

  end
end
