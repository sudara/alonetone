# == Schema Information
#
# Table name: audio_features
#
#  id         :bigint(8)        not null, primary key
#  asset_id   :bigint(8)
#  waveform   :text(16777215)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AudioFeature < ActiveRecord::Base

  serialize :waveform, Array

  belongs_to :asset
end
