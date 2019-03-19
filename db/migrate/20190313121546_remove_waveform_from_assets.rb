class RemoveWaveformFromAssets < ActiveRecord::Migration[5.2]
  def change
    remove_column :assets, :waveform, :text
  end
end
