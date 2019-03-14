# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachedValidator do
  class AttachedValidatorModel
    include ActiveModel::Validations

    attr_reader :audio_file
    attr_reader :video_file

    def initialize(audio_file, video_file)
      @audio_file = audio_file
      @video_file = video_file
    end

    validates :audio_file, attached: {
      content_type: %w[audio/mpeg audio/mp3 audio/x-mp3],
      byte_size: { less_than: 60.megabytes }
    }
    validates :video_file, attached: {
      byte_size: { allow_empty: true, greater_than: 10.megabyte }
    }
  end

  it 'allows nil' do
    record = AttachedValidatorModel.new(nil, nil)
    expect(record).to be_valid
  end

  it 'allows valid attachement' do
    record = AttachedValidatorModel.new(
      double(
        content_type: 'audio/mpeg',
        byte_size: 30.kilobytes.to_i
      ),
      nil
    )
    expect(record).to be_valid
  end

  it 'allows empty attachment when configured to do so' do
    record = AttachedValidatorModel.new(nil, double(byte_size: 0))
    expect(record).to be_valid
  end

  it 'does not allow attachment with unsupported content-type' do
    record = AttachedValidatorModel.new(
      double(
        content_type: 'application/octet-stream',
        byte_size: 30.kilobytes.to_i
      ),
      nil
    )
    expect(record).to_not be_valid
    expect(record.errors.details[:audio_file]).to eq(
      [
        error: :invalid_content_type,
        accepted: %w[audio/mpeg audio/mp3 audio/x-mp3],
        accepted_sentence: 'audio/mpeg, audio/mp3, and audio/x-mp3',
        value: 'application/octet-stream'
      ]
    )
  end

  it 'does not allow empty attachment' do
    record = AttachedValidatorModel.new(
      double(
        content_type: 'audio/mpeg',
        byte_size: 0
      ),
      nil
    )
    expect(record).to_not be_valid
    expect(record.errors.details[:audio_file]).to eq(
      [error: :blank, value: 0]
    )
  end

  it 'does not allow attachment that is too small' do
    record = AttachedValidatorModel.new(
      nil,
      double(byte_size: 30.kilobytes)
    )
    expect(record).to_not be_valid
    expect(record.errors.details[:video_file]).to eq(
      [
        error: :byte_size_too_small,
        greater_than: 10485760,
        greater_than_human_size: '10 MB',
        value: 30720
      ]
    )
  end

  it 'does not allow attachment that is too large' do
    record = AttachedValidatorModel.new(
      double(
        content_type: 'audio/mpeg',
        byte_size: 2.gigabytes.to_i
      ),
      nil
    )
    expect(record).to_not be_valid
    expect(record.errors.details[:audio_file]).to eq(
      [
        error: :byte_size_too_large,
        value: 2.gigabytes.to_i,
        less_than: 60.megabytes,
        less_than_human_size: '60 MB'
      ]
    )
  end
end
