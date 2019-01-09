# frozen_string_literal: true

require 'rails_helper'
require 'paperclip_processors/mp3_paperclip_processor'

RSpec.describe Paperclip::Mp3PaperclipProcessor, :model do
  let(:asset) { Asset.new }
  let(:mp3_file) { file_fixture_tempfile(mp3_file_filename) }
  let(:attachment) { Paperclip::Attachment.new('mp3', asset) }
  let(:processor) { Paperclip::Mp3PaperclipProcessor.new(mp3_file, {}, attachment) }

  context 'operating on MP3 with ID3 data' do
    let(:mp3_file_filename) { 'piano.mp3' }

    it 'extracts ID3 information and applies to an Assset' do
      expect(processor.make).to be_kind_of(File)
      expect(asset.album).to eq('Polderkaas')
      expect(asset.artist).to eq('Henri Willig')
      expect(asset.bitrate).to eq(64)
      expect(asset.genre).to eq('Rock')
      expect(asset.id3_track_num).to eq(2)
      expect(asset.length).to eq('0:04')
      expect(asset.samplerate).to eq(44100)
      expect(asset.title).to eq('Piano')
    end
  end

  context 'operating on MP3 with other ID3 data' do
    let(:mp3_file_filename) { 'muppets.mp3' }

    it 'extracts ID3 information and applies to an Assset' do
      expect(processor.make).to be_kind_of(File)
      expect(asset.album).to be_nil
      expect(asset.artist).to eq('Old Muppet Men')
      expect(asset.bitrate).to eq(192)
      expect(asset.genre).to eq('Comedy')
      expect(asset.id3_track_num).to be_nil
      expect(asset.length).to eq("0:13")
      expect(asset.samplerate).to eq(44100)
      expect(asset.title).to eq('Old Muppet Men Booing')
    end
  end

  context 'operating on blank MP3' do
    let(:mp3_file_filename) { 'empty.mp3' }

    it 'raises an exception' do
      expect do
        processor.make
      end.to raise_error(Paperclip::Error)
    end
  end
end
