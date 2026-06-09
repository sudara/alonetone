require 'rails_helper'

RSpec.describe Admin::DashboardStats do
  describe 'all-time (unbounded range)' do
    subject(:stats) { described_class.new(range: nil, bucket: :month, range_key: 'all') }

    it 'counts all non-deleted records' do
      expect(stats.new_users).to eq(User.count)
      expect(stats.new_tracks).to eq(Asset.count)
      expect(stats.new_comments).to eq(Comment.count)
    end

    it 'uses cached listen counts instead of scanning the listens table' do
      expect(stats.listens).to eq(Asset.with_deleted.sum(:listens_count))
    end

    it 'returns a month-bucketed series' do
      expect(stats.new_users_series).to be_a(Hash)
    end

    it 'skips the listens series rather than grouping the whole listens table' do
      expect(stats.listens_series).to be_nil
    end
  end

  describe 'bounded range' do
    subject(:stats) { described_class.new(range: range, bucket: :day, range_key: '30d') }

    let(:range) { 30.days.ago..Time.current }

    it 'only counts records created within the range' do
      expect(stats.new_users).to eq(User.where(created_at: range).count)
    end

    it 'gap-fills daily buckets whose values sum to the range total' do
      series = stats.new_tracks_series
      expect(series.keys).to all(be_a(Date))
      expect(series.values.sum).to eq(stats.new_tracks)
    end

    it 'counts listens within the range from the listens table' do
      expect(stats.listens).to eq(Listen.where(created_at: range).count)
    end

    it 'returns a listens series whose values sum to the range total' do
      expect(stats.listens_series.values.sum).to eq(stats.listens)
    end
  end

  describe 'series caching' do
    before do
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
    end

    it 'serves repeat series requests for the same range from the cache' do
      first = described_class.new(range: nil, bucket: :month, range_key: 'all').new_users_series
      expect(User).not_to receive(:group_by_month)
      second = described_class.new(range: nil, bucket: :month, range_key: 'all').new_users_series
      expect(second).to eq(first)
    end

    it 'caches each range separately' do
      all_time = described_class.new(range: nil, bucket: :month, range_key: 'all').new_users_series
      range = 7.days.ago..Time.current
      bounded = described_class.new(range: range, bucket: :day, range_key: '7d').new_users_series
      expect(bounded.values.sum).to eq(User.where(created_at: range).count)
      expect(bounded.keys).not_to eq(all_time.keys)
      expect(described_class.new(range: nil, bucket: :month, range_key: 'all').new_users_series).to eq(all_time)
    end
  end

  describe 'moderation badges' do
    subject(:stats) { described_class.new(range: nil, bucket: :month, range_key: 'all') }

    it 'reports spam and purge-eligible counts' do
      expect(stats.spam_tracks).to eq(Asset.with_deleted.where(is_spam: true).count)
      expect(stats.spam_comments).to eq(Comment.where(is_spam: true).count)
      expect(stats.perma_deletable).to eq(User.destroyable.count + Asset.destroyable.count)
    end
  end
end
