# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload::Metadata, type: :model do
  let(:metadata) do
    Upload::Metadata.new(file_fixture_tempfile(filename))
  end

  context 'valid MP3 with ID3 tags' do
    let(:filename) { 'piano.mp3' }

    it 'returns all attributes' do
      expect(metadata.attributes).to eq(
        album: 'Polderkaas',
        artist: 'Henri Willig',
        bitrate: 64,
        genre: 'Rock',
        id3_track_num: 2,
        length: 4.51925,
        samplerate: 44100,
        title: 'Piano'
      )
    end
  end

  context 'valid MP3 with ID3 tags with completely broken character encoding' do
    let(:filename) { 'japanese-characters.mp3' }

    it 'returns all attributes' do
      expect(metadata.attributes).to eq(
        album: 'Îa°®×öμÄÉμÊÂ'.unicode_normalize(:nfc),
        artist: ' ́÷°®Áá'.unicode_normalize(:nfc),
        bitrate: 192,
        genre: '(13)Pop',
        id3_track_num: 1,
        length: 277.78608333333335,
        samplerate: 44100,
        title: '01-¶ÔμÄÈË'.unicode_normalize(:nfc)
      )
    end
  end

  context 'valid MP3 without ID3 tags' do
    let(:filename) { 'emptytags.mp3' }

    it 'returns all attributes' do
      expect(metadata.attributes).to eq(
        bitrate: 128,
        length: 213.451875,
        samplerate: 44100
      )
    end
  end

  context 'empty file' do
    let(:filename) { 'empty.mp3' }

    it 'does not return attributes' do
      expect(metadata.attributes).to be_empty
    end
  end

  context 'not an MP3' do
    let(:filename) { 'smallest.zip' }

    it 'does not return attributes' do
      expect(metadata.attributes).to be_empty
    end
  end
end
