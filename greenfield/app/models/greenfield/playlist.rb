module Greenfield
  class Playlist < ActiveRecord::Base
    belongs_to :user

    has_many :playlist_tracks
    has_many :posts, :through => :playlist_tracks, :source => :post

    attr_accessible :title
    validates_presence_of :title

    has_permalink :title, true
  end
end
