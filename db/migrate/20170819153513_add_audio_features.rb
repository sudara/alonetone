class AddAudioFeatures < ActiveRecord::Migration[5.1]
  def change
    create_table :audio_features do |t|
      t.references(:asset, index: true)
      t.text :waveform
      t.timestamps
    end
  end
end
