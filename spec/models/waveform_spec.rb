# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Waveform do
  it 'processes a file on disk without raising errors' do
    data = Waveform.extract(file_fixture_pathname('muppets.mp3').to_s)
    expect(data).to_not be_empty
    data.each { |sample| expect(sample).to be_kind_of(Numeric) }
  end
end
