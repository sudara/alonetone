# frozen_string_literal: true

class Asset < ApplicationRecord
  module Waveform
    def import_waveform
      Tempfile.open(%w[mp3-download .mp3]) do |tempfile|
        mp3.copy_to_local_file(:original, tempfile.path)
        update!(
          audio_feature_attributes: {
            waveform: ::Waveform.extract(tempfile.path)
          }
        )
      end
    end
  end
end
