# frozen_string_literal: true

class Asset < ApplicationRecord
  module Waveform
    def import_waveform
      audio_file.open do |file|
        feature = audio_feature || build_audio_feature
        feature.update!(waveform: ::Waveform.extract(file.path))
      end
    end
  end
end
