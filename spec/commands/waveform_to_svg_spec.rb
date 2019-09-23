require 'rails_helper'

RSpec.describe WaveformToSvg do

  subject { WaveformToSvg.new([1, 2, 3, 2, 1]) }

  it "takes an array and scales it down" do
    expect(subject.data[3]).to be < 1
  end

  it "spits out svg polygon points" do
    expect(subject.points).to eq " 0,27.0 1,27.0 2,0.0 3,27.0 4,27.0 4,27.0 3,27.0 2,54.0 1,27.0 0,27.0"
  end

  it "uses a default when no data is given" do
    waveform = WaveformToSvg.new([])
    expect(waveform.data.length).to be > 10
  end
end
