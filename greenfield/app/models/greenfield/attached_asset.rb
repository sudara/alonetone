module Greenfield
  class AttachedAsset < ActiveRecord::Base
    belongs_to :post
    has_one :user, through: :post
    has_one :alonetone_asset, through: :post, source: :asset

    serialize :waveform, Array

    has_one_attached :audio_file

    def permalink
      "#{id}-@attachment"
    end

    def length
      Asset.formatted_time(self[:length])
    end
  end
end
