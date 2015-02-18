module Greenfield
  class PlaylistTrack < ActiveRecord::Base
    belongs_to :playlist
    belongs_to :post
    has_one :alonetone_asset, :through => :post, :source => :asset

    acts_as_list :scope => :playlist_id, :order => :position
  end
end
