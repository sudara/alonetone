class ChangeWaveformToMediumText < ActiveRecord::Migration
  def change
    change_column :assets, :waveform, :text, :limit => 16777215
    change_column :greenfield_attached_assets, :waveform, :text, :limit => 16777215
  end
end
