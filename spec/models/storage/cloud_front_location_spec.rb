# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Storage::CloudFrontLocation, type: :model do
  let(:amazon_cloud_front_domain_name) { 'xxxxxxxxxxxxxx.cloudfront.net' }
  let(:amazon_cloud_front_key_pair_id) { 'XXXXXXXXXXXXXXXXXXXX' }
  let(:key) { SecureRandom.hex(32) }

  let(:location) do
    Storage::CloudFrontLocation.new(
      key, signed: signed
    )
  end

  let(:base_url) do
    'https://' +
      amazon_cloud_front_domain_name +
      '/' +
      key
  end

  around do |example|
    with_alonetone_configuration(
      amazon_cloud_front_domain_name: amazon_cloud_front_domain_name,
      amazon_cloud_front_key_pair_id: amazon_cloud_front_key_pair_id,
      amazon_cloud_front_private_key: generate_amazon_cloud_front_private_key
    ) do
      example.call
    end
  end

  it "does not initialize without signed argument" do
    expect do
      Storage::CloudFrontLocation.new(key)
    end.to raise_error(ArgumentError)
  end

  it "does not initialize when key is nil" do
    expect do
      Storage::CloudFrontLocation.new(nil, signed: false)
    end.to raise_error(ArgumentError)
  end

  it "does not initialize when key is blank" do
    expect do
      Storage::CloudFrontLocation.new(' ', signed: false)
    end.to raise_error(ArgumentError)
  end

  it "coerces to string" do
    expect(
      Storage::CloudFrontLocation.new(key, signed: false).to_s
    ).to start_with('http://')
  end

  context "unsigned" do
    let(:signed) { false }

    it "is not signed" do
      expect(location).to_not be_signed
    end

    it "generates a URL to an object on S3" do
      url = location.url
      uri = URI.parse(url)
      expect(url).to start_with(base_url)
      expect(uri.query).to be_nil
    end
  end

  context "signed" do
    let(:signed) { true }

    it "is signed" do
      expect(location).to be_signed
    end

    it "generates a URL to an object on S3" do
      url = location.url
      uri = URI.parse(url)
      expect(url).to start_with(base_url)
      params = Rack::Utils.parse_query(uri.query)
      expect(params.keys.sort).to eq(
        %w[
          Expires
          Key-Pair-Id
          Signature
        ]
      )
    end
  end
end
