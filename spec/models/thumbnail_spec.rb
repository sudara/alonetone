# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Thumbnail, type: :model do
  let(:playlist) { playlists(:will_studd_rockfort) }
  let(:attachment) { playlist.cover_image }
  let(:thumbnail) { Thumbnail.new(key) }
  let(:stream) { StringIO.new }

  context "with existing and usable image" do
    let(:key) { attachment.key }

    it "returns a set of headers to use when serving the thumbnail" do
      headers = thumbnail.headers
      expect(headers.keys.sort).to eq(
        %w[
          Cache-Control
          Content-Type
          ETag
          Expires
        ]
      )
      expect(headers['Cache-Control']).to eq('max-age=3600, public')
      expect(headers['Content-Type']).to eq('image/jpeg')
      expect(headers['ETag'].length).to eq(42)
      expect(headers['ETag']).to start_with('"')
      expect(headers['ETag']).to end_with('"')
      expect(headers['Expires']).to start_with((Time.zone.now + 3600).strftime('%a, %d %b %Y'))
      expect(headers['Expires']).to end_with('GMT')
    end

    context "without transformation parameters" do
      it "writes JPEG data to an output IO" do
        thumbnail.write(stream)
        expect(stream.string).to start_with("\xFF\xD8\xFF\xDB")
      end
    end

    context "with transformation parameters" do
      let(:thumbnail) { Thumbnail.new(key, crop: '16:9', width: 640, quality: 42) }

      it "writes JPEG data to an output IO" do
        thumbnail.write(stream)
        expect(stream.string).to start_with("\xFF\xD8\xFF\xDB")
      end
    end
  end

  context "with non-existent image" do
    let(:key) { 'non-existent' }

    it "raises an exception when writing JPEG data to an output IO" do
      assert_raises(ActiveRecord::RecordNotFound) do
        thumbnail.write(stream)
      end
    end
  end

  describe "cropped dimensions" do
    it "calculates a portrait crop in a landscape image" do
      dimensions = Thumbnail.crop_dimensions(width: 1023, height: 761, crop: '1:4')
      expect(dimensions).to eq([190, 761])
    end

    it "calculates a landscape crop in a landscape image" do
      dimensions = Thumbnail.crop_dimensions(width: 1023, height: 761, crop: '4:1')
      expect(dimensions).to eq([1023, 255])

      dimensions = Thumbnail.crop_dimensions(width: 4005, height: 120, crop: '4:1')
      expect(dimensions).to eq([480, 120])
    end

    it "calculates a portrait crop in a portrait image" do
      dimensions = Thumbnail.crop_dimensions(width: 98, height: 567, crop: '1:4')
      expect(dimensions).to eq([98, 392])

      dimensions = Thumbnail.crop_dimensions(width: 477, height: 2041, crop: '1:4')
      expect(dimensions).to eq([477, 1908])
    end

    it "calculates a landscape crop in a portrait image" do
      dimensions = Thumbnail.crop_dimensions(width: 377, height: 1041, crop: '4:1')
      expect(dimensions).to eq([377, 94])
    end
  end
end
