class CreateAudioFeatureJob < ApplicationJob
  queue_as :default

  def perform(asset_id)
    asset = Asset.find(asset_id)
    return unless asset.audio_file.attached?

    asset.import_waveform
  end
end
