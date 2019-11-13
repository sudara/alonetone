# frozen_string_literal: true

require 'slug'

class Playlist < ActiveRecord::Base
end

class MakePlaylistPermalinksUniqueWithinScope < ActiveRecord::Migration[6.0]
  def up
    Playlist.find_each do |playlist|
      playlist.reload

      duplicates = Playlist
                   .where(permalink: playlist.permalink)
                   .where(user_id: playlist.user_id)
                   .where.not(id: playlist.id)
                   .order(id: :asc).to_a
      next if duplicates.empty?

      slug = Slug.generate(playlist.title)
      duplicates.each do |duplicate|
        slug = Slug.increment(slug)
        duplicate.update_column(:permalink, slug)
      end
    end
  end

  def down; end
end
