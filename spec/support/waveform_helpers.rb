# frozen_string_literal: true

module RSpec
  module Support
    module WaveformHelpers
      def waveform
        @waveform ||= generate_waveform
      end

      # Generates an array of 500 large integers which
      # should resemble a sine shape when rendered.
      def generate_waveform
        waveform = []
        1.upto(500) do |i|
          positive_sine = Math.sin(i / 10.0) + 1
          waveform << (positive_sine * 1000000).round
        end
        waveform
      end
    end
  end
end
