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
