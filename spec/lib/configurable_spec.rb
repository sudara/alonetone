# frozen_string_literal: true

require 'spec_helper'
require 'configurable'

RSpec.describe Configurable do
  let(:hostname) { 'alonetone.example.com' }

  it "initializes" do
    expect do
      configurable = Configurable.new('test', hostname: hostname)
      expect(configurable.hostname).to eq(hostname)
    end.to_not output.to_stdout
  end

  it "rewrites deprecated configuration keys" do
    expect do
      configurable = Configurable.new('test', url: hostname)
      expect(configurable.hostname).to eq(hostname)
    end.to output.to_stdout
  end

  it "prints deprecated configuration keys" do
    expect do
      configurable = Configurable.new('development', url: hostname, unknown: 1)
    end.to output(
      "[!] Please apply the following changes to `config/alonetone.yml' in development:\n\n" \
      " * Remove unknown\n" \
      " * Replace url with hostname\n"
    ).to_stdout
  end
end
