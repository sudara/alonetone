# frozen_string_literal: true

require 'rails_helper'

RSpec.describe License, type: :model do
  context 'version 4.0' do
    let(:license) { License.new('by-nc-sa/4.0') }

    it 'has a label' do
      expect(license.label).to eq('Attribution-Noncommercial-Share Alike')
    end

    it 'has a full label' do
      expect(license.full_label).to eq('Attribution-Noncommercial-Share Alike 4.0 International')
    end

    it 'has a short label' do
      expect(license.short_label).to eq('BY-NC-SA 4.0')
    end

    it 'has an url to the full license' do
      expect(license.url).to eq('https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en')
    end

    it 'knows its jurisdiction' do
      expect(license.jurisdiction).to eq('international')
    end
  end

  it 'uses the abbreviation as its name' do
    expect(License.new('by/1.0').name).to eq('by')
  end

  it 'finds a licence by ID' do
    expect(License.find('by').name_with_version).to eq('by/4.0')
  end

  it 'does not find an unknown license' do
    expect(License.find('defined-in-content')).to be_nil
  end

  it 'knows which licenses it supports natively' do
    %w[
      by/4.0
    ].each do |license_code|
      expect(License.supported?(license_code)).to eq(true)
    end
  end

  it 'knows which licenses does not support natively' do
    %w[
      by
      unknown
    ].each do |license_code|
      expect(License.supported?(license_code)).to eq(false)
    end
  end

  it 'supports all-rights-reserved as an alternative to CC licenses' do
    license = License.new('all-rights-reserved')
    expect(license.supported?).to eq(true)
    expect(license.url).to be_nil
  end

  it 'knows if the version is current' do
    %W[
      all-rights-reserved
      defined-in-content
      by-nc-sa/#{License::CURRENT_VERSION}
    ].each do |value|
      expect(License.new(value).current?).to eq(true)
    end
  end

  it 'knows if the version is not current' do
    %W[
      by-nc-sa/1.0
      by-nc-sa/3.1
      by-nc-sa/3.0
      by-nc-sa/99.9.9
      unknown
    ].each do |value|
      expect(License.new(value).current?).to eq(false)
    end
  end

  it 'returns the current version of the selected license' do
    {
      'all-rights-reserved' => 'all-rights-reserved',
      'defined-in-content' => 'defined-in-content',
      'by-nc-sa/1.0' => "by-nc-sa/#{License::CURRENT_VERSION}"
    }.each do |example, expected|
      expect(License.new(example).current_version.name_with_version).to eq(expected)
    end
  end
end
