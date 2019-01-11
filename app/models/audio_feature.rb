class AudioFeature < ActiveRecord::Base
  serialize :waveform, Array

  belongs_to :asset
end

# == Schema Information
#
# Table name: audio_features
#
#  id         :bigint(8)        not null, primary key
#  waveform   :text(4294967295)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  asset_id   :bigint(8)
#
# Indexes
#
#  index_audio_features_on_asset_id  (asset_id)
#
