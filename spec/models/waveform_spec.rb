# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Waveform do
  context 'operating on an audio file' do
    let(:path) do
      file_fixture_pathname('muppets.mp3').to_s
    end

    it 'generates RMS samples' do
      data = Waveform.extract(path)
      expect(data).to_not be_empty
      expect(data.length).to be_within(1).of(500)
      data.each { |sample| expect(sample).to be_kind_of(Numeric) }
    end
  end

  context 'operating on an empty audio file' do
    let(:path) do
      file_fixture_pathname('empty.mp3').to_s
    end

    it 'generates no data' do
      expect(Waveform.extract(path)).to be_nil
    end
  end

  context 'operating on a non-audio file' do
    let(:path) do
      file_fixture_pathname('smallest.zip').to_s
    end

    it 'generates no data' do
      expect(Waveform.extract(path)).to be_nil
    end
  end

  context 'when audiowaveform returns fewer samples than LENGTH' do
    # 80 samples → slice_size = 0.16, buckets jump by ~6 leaving nil holes — used to crash Math.sqrt.
    let(:short_json) { { 'data' => (1..80).to_a }.to_json }
    let(:status) { instance_double(Process::Status, exitstatus: 0) }

    before do
      allow(Open3).to receive(:capture2).and_return([short_json, status])
    end

    it 'returns a numeric waveform without raising' do
      data = nil
      expect { data = Waveform.extract('any/path.mp3') }.not_to raise_error
      expect(data).to be_an(Array)
      data.each { |sample| expect(sample).to be_kind_of(Numeric) }
    end
  end
end
