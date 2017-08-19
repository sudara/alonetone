class MoveWaveformData < ActiveRecord::Migration[5.1]
  def up
    change_column :audio_features, :waveform, :text, :limit => 16777215
    Asset.where('waveform is not null').each do |asset|
      asset.create_audio_feature(waveform: asset.waveform) if asset.waveform.present?
    end
  end

  def down
  end
end
