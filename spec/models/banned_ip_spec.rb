require 'rails_helper'

RSpec.describe BannedIp do
  before { described_class.clear_cache }

  it 'reports whether an ip is banned' do
    described_class.create!(ip: '203.0.113.9')
    described_class.clear_cache
    expect(described_class.banned?('203.0.113.9')).to be(true)
    expect(described_class.banned?('10.0.0.1')).to be(false)
    expect(described_class.banned?(nil)).to be(false)
  end

  it 'matches ips covered by a CIDR range ban' do
    described_class.create!(ip: '47.82.0.0/16')
    described_class.clear_cache
    expect(described_class.banned?('47.82.10.35')).to be(true)
    expect(described_class.banned?('47.83.0.1')).to be(false)
  end

  it 'matches ipv6 ips covered by a range ban' do
    described_class.create!(ip: '2001:db8::/32')
    described_class.clear_cache
    expect(described_class.banned?('2001:db8::beef')).to be(true)
    expect(described_class.banned?('2001:db9::1')).to be(false)
  end

  it 'normalizes a range to its masked network address' do
    expect(described_class.create!(ip: '47.82.9.9/16').ip).to eq('47.82.0.0/16')
  end

  it 'collapses a full-length prefix to an exact ip' do
    expect(described_class.create!(ip: '203.0.113.7/32').ip).to eq('203.0.113.7')
  end

  it 'rejects an invalid prefix length' do
    expect(described_class.new(ip: '47.82.0.0/99')).not_to be_valid
  end

  it 'is not banned for a garbage lookup value' do
    described_class.create!(ip: '47.82.0.0/16')
    described_class.clear_cache
    expect(described_class.banned?('not-an-ip')).to be(false)
  end

  it 'requires a unique ip' do
    described_class.create!(ip: '203.0.113.10')
    expect(described_class.new(ip: '203.0.113.10')).not_to be_valid
  end

  it 'requires an ip' do
    expect(described_class.new(ip: '')).not_to be_valid
  end

  it 'rejects a value that is not a valid IP address' do
    expect(described_class.new(ip: 'not-an-ip')).not_to be_valid
    expect(described_class.new(ip: '203.0.113.1')).to be_valid
    expect(described_class.new(ip: '2001:db8::1')).to be_valid
  end

  describe 'cache-backed lookup' do
    let(:memory) { ActiveSupport::Cache::MemoryStore.new }

    before { allow(Rails).to receive(:cache).and_return(memory) }

    it 'serves banned? from the cache and only refetches once cleared' do
      described_class.create!(ip: '203.0.113.50')
      described_class.clear_cache
      expect(described_class.banned?('203.0.113.50')).to be(true) # fetched into cache

      described_class.where(ip: '203.0.113.50').delete_all # skip callbacks, leave cache stale
      expect(described_class.banned?('203.0.113.50')).to be(true) # still served from cache

      described_class.clear_cache
      expect(described_class.banned?('203.0.113.50')).to be(false) # refetched, gone
    end
  end
end
