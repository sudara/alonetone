# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Listens, type: :model do
  context "when CloudFront is configured" do
    let(:asset) do
      assets(:will_studd_rockfort_combalou)
    end
    let(:amazon_cloud_front_domain_name) { 'xxxxxxxxxxxxxx.cloudfront.net' }
    let(:amazon_cloud_front_key_pair_id) { 'XXXXXXXXXXXXXXXXXXXX' }
    let(:url) do
      'https://' +
        amazon_cloud_front_domain_name +
        '/mp3s/' +
        Rack::Utils.escape(asset.mp3_file_name)
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

    it "returns a CloudFront signer instance" do
      expect(Listens.cloud_front_signer).to be_kind_of(Aws::CloudFront::UrlSigner)
    end

    it "signs a CloudFront URL" do
      signed_url = Listens.cloudfront_url(url)
      signed_uri = URI.parse(signed_url)
      expect(signed_url).to start_with('https://')
      params = Rack::Utils.parse_query(signed_uri.query)
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
