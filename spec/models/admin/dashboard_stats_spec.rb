require 'rails_helper'

RSpec.describe Admin::DashboardStats do
  describe 'all-time (unbounded range)' do
    subject(:stats) { described_class.new(range: nil, bucket: :month) }

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
  end

  describe 'bounded range' do
    subject(:stats) { described_class.new(range: range, bucket: :day) }

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
  end

  describe 'moderation badges' do
    subject(:stats) { described_class.new(range: nil, bucket: :month) }

    it 'reports spam and purge-eligible counts' do
      expect(stats.spam_tracks).to eq(Asset.with_deleted.where(is_spam: true).count)
      expect(stats.spam_comments).to eq(Comment.where(is_spam: true).count)
      expect(stats.perma_deletable).to eq(User.destroyable.count + Asset.destroyable.count)
    end
  end
end
