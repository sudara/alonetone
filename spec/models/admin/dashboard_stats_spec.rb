require 'rails_helper'

RSpec.describe Admin::DashboardStats do
  describe 'all-time (unbounded range)' do
    subject(:stats) { described_class.new(range: nil, bucket: :month, range_key: 'all') }

    it 'counts all non-deleted records' do
      expect(stats.new_users).to eq(User.count)
      expect(stats.new_tracks).to eq(Asset.count)
      expect(stats.new_comments).to eq(Comment.where(is_spam: false).count)
      expect(stats.new_spam_comments).to eq(Comment.with_deleted.where(is_spam: true).count)
      expect(stats.total_users).to eq(User.count)
      expect(stats.total_tracks).to eq(Asset.count)
      expect(stats.total_comments).to eq(Comment.where(is_spam: false).count)
      expect(stats.total_listens).to eq(Asset.with_deleted.sum(:listens_count))
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

    it 'counts only non-spam comments as new comments' do
      asset = assets(:valid_mp3)
      Comment.create!(commentable: asset, commenter: users(:arthur), body: 'not spam', created_at: 1.day.ago)
      Comment.create!(commentable: asset, commenter: users(:arthur), body: 'spam', is_spam: true,
        created_at: 1.day.ago, deleted_at: 1.hour.ago)

      expect(stats.new_comments).to eq(Comment.where(created_at: range, is_spam: false).count)
      expect(stats.new_spam_comments).to eq(Comment.with_deleted.where(created_at: range, is_spam: true).count)
      expect(stats.new_comments_series.values.sum).to eq(stats.new_comments)
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

  describe 'top users' do
    subject(:stats) { described_class.new(range: range, bucket: :day, range_key: '30d') }

    let(:range) { 2.years.ago..1.year.ago }
    let(:in_range) { 18.months.ago }

    it 'ranks commenters by comments within the range, excluding spam and guests' do
      asset = assets(:valid_mp3)
      Comment.create!(commentable: asset, commenter: users(:arthur), body: 'one', created_at: in_range)
      Comment.create!(commentable: asset, commenter: users(:arthur), body: 'two', created_at: in_range)
      Comment.create!(commentable: asset, commenter: users(:sudara), body: 'three', created_at: in_range)
      Comment.create!(commentable: asset, commenter: users(:sudara), body: 'spam', is_spam: true, created_at: in_range)
      Comment.create!(commentable: asset, commenter: nil, body: 'guest', created_at: in_range)

      expect(stats.top_commenters).to eq([[users(:arthur), 2], [users(:sudara), 1]])
    end

    it 'ranks uploaders by tracks created within the range' do
      Asset.where(user: users(:sudara)).limit(2).update_all(created_at: in_range)
      Asset.where(user: users(:will_studd)).limit(1).update_all(created_at: in_range)

      expect(stats.top_uploaders).to eq([[users(:sudara), 2], [users(:will_studd), 1]])
    end

    it 'drops soft-deleted users from the list' do
      asset = assets(:valid_mp3)
      Comment.create!(commentable: asset, commenter: users(:arthur), body: 'one', created_at: in_range)
      users(:arthur).update_columns(deleted_at: Time.current)

      expect(stats.top_commenters).to be_empty
    end

    it 'ranks all-time commenters by comments authored, not comments received' do
      asset = assets(:valid_mp3)
      30.times { |i| Comment.create!(commentable: asset, commenter: users(:jamie_kiesl), body: "c#{i}") }

      all_time = described_class.new(range: nil, bucket: :month, range_key: 'all')
      expect(all_time.top_commenters.first.first).to eq(users(:jamie_kiesl))
      expect(all_time.top_commenters.first.last).to be >= 30
    end

    it 'ranks all-time uploaders by the assets_count counter cache' do
      users(:jamie_kiesl).update_columns(assets_count: 999)

      all_time = described_class.new(range: nil, bucket: :month, range_key: 'all')
      expect(all_time.top_uploaders.first).to eq([users(:jamie_kiesl), 999])
    end
  end

  describe 'moderation badges' do
    subject(:stats) { described_class.new(range: nil, bucket: :month, range_key: 'all') }

    it 'reports spam and purge-eligible counts' do
      comments(:public_comment_on_asset_by_user).update_columns(deleted_at: 40.days.ago)
      Comment.create!(commentable: assets(:valid_mp3), commenter: users(:arthur), body: 'hidden spam',
        is_spam: true, deleted_at: 1.day.ago)

      expect(stats.spam_tracks).to eq(Asset.with_deleted.where(is_spam: true).count)
      expect(stats.spam_comments).to eq(Comment.with_deleted.where(is_spam: true).count)
      expect(stats.perma_deletable).to eq(
        User.destroyable.count + Asset.destroyable.count + Comment.destroyable.count
      )
    end
  end
end
