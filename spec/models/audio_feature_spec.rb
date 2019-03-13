# frozen_string_literal: true

require "rails_helper"

RSpec.describe AudioFeature, type: :model do
  it 'returns its waveform' do
    waveform = audio_features(:will_studd_rockfort_combalou).waveform
    expect(waveform.size).to eq(500)
  end
end
