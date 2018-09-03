class CreateAudioFeatureJob < ApplicationJob
  queue_as :default

  def perform(asset_id)
    asset = Asset.find(asset_id)

    asset&.import_waveform
  end
end
