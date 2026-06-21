require 'rails_helper'

RSpec.describe PurgeEligibleRecordsJob do
  it 'permanently destroys accounts soft-deleted more than 30 days ago' do
    user = users(:arthur)
    user.update_columns(deleted_at: 40.days.ago)

    described_class.new.perform

    expect(User.with_deleted.exists?(user.id)).to be(false)
  end

  it 'leaves recently soft-deleted accounts alone' do
    user = users(:arthur)
    user.update_columns(deleted_at: 5.days.ago)

    described_class.new.perform

    expect(User.with_deleted.exists?(user.id)).to be(true)
  end

  it 'can skip asset purging for an account-only run' do
    asset = assets(:spam_track)

    described_class.new.perform(assets: false)

    expect(Asset.with_deleted.exists?(asset.id)).to be(true)
  end

  it 'can skip account purging for an asset-only run' do
    user = users(:deleted_30_days_ago)

    described_class.new.perform(users: false)

    expect(User.with_deleted.exists?(user.id)).to be(true)
  end

  it 'permanently destroys soft-deleted comments older than 30 days' do
    comment = comments(:public_comment_on_asset_by_user)
    comment.update_columns(deleted_at: 40.days.ago)

    described_class.new.perform(users: false, assets: false)

    expect(Comment.with_deleted.exists?(comment.id)).to be(false)
  end

  it 'leaves spam comments that were never soft-deleted alone' do
    comment = Comment.create!(commentable: assets(:valid_mp3), commenter: users(:arthur), body: 'old spam',
      is_spam: true, updated_at: 40.days.ago)

    described_class.new.perform(users: false, assets: false)

    expect(Comment.with_deleted.exists?(comment.id)).to be(true)
  end

  it 'leaves recently soft-deleted comments alone' do
    deleted = comments(:public_comment_on_asset_by_user)
    deleted.update_columns(deleted_at: 5.days.ago)

    described_class.new.perform(users: false, assets: false)

    expect(Comment.with_deleted.exists?(deleted.id)).to be(true)
  end

  it 'can skip comment purging' do
    comment = comments(:public_comment_on_asset_by_user)
    comment.update_columns(deleted_at: 40.days.ago)

    described_class.new.perform(users: false, assets: false, comments: false)

    expect(Comment.with_deleted.exists?(comment.id)).to be(true)
  end

  it 'can dry-run without deleting eligible records' do
    user = users(:deleted_30_days_ago)
    asset = assets(:spam_track)
    comment = comments(:public_comment_on_asset_by_user)
    comment.update_columns(deleted_at: 40.days.ago)

    described_class.new.perform(dry_run: true)

    expect(User.with_deleted.exists?(user.id)).to be(true)
    expect(Asset.with_deleted.exists?(asset.id)).to be(true)
    expect(Comment.with_deleted.exists?(comment.id)).to be(true)
  end

  it 'can limit the number of records purged per type' do
    users(:arthur).update_columns(deleted_at: 40.days.ago)

    expect do
      described_class.new.perform(assets: false, limit: 1)
    end.to change { User.with_deleted.count }.by(-1)
  end
end
