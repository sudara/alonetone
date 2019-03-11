module Greenfield
  class WaveformExtractJob < ActiveJob::Base
    queue_as :default

    def perform(alonetone_asset_id)
      Asset.find(alonetone_asset_id).import_waveform
    end
  end
end
