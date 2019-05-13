# frozen_string_literal: true

class Asset < ApplicationRecord
  module Waveform
    def import_waveform
      audio_file.open do |file|
        update!(
          audio_feature_attributes: { waveform: ::Waveform.extract(file.path) }
        )
      end
    end
  end
end
