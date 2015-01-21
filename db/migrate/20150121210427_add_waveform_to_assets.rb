class AddWaveformToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :waveform, :text
  end
end
