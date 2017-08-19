class AudioFeature < ActiveRecord::Base

  serialize :waveform, Array

  belongs_to :asset
end