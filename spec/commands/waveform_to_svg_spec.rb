require 'rails_helper'

RSpec.describe WaveformToSvg do

  subject { WaveformToSvg.new([1, 2, 3, 2, 1]) }

  it "takes an array and scales it down" do
    expect(subject.data[3]).to be < 1
  end

  it "spits out svg polygon points" do
    expect(subject.points).to eq " 0,14.486497467156815 1,6.671755161776602 2,0.0 3,6.671755161776602 4,14.486497467156815 4,39.513502532843184 3,47.3282448382234 2,54.0 1,47.3282448382234 0,39.513502532843184"
  end

  it "uses a default when no data is given" do
    waveform = WaveformToSvg.new([])
    expect(waveform.data.length).to be > 10
  end
end
