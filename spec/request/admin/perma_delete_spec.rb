require 'rails_helper'

RSpec.describe 'Admin perma-delete', type: :request do
  before { create_user_session(users(:sudara)) }

  describe 'purging a user' do
    let(:user) { users(:arthur) }

    it 'hard-deletes a user soft-deleted more than 30 days ago' do
      user.update_columns(deleted_at: 40.days.ago)
      expect do
        delete purge_admin_user_path(user.login)
      end.to change { User.with_deleted.exists?(user.id) }.from(true).to(false)
    end

    it 'refuses to purge a user soft-deleted less than 30 days ago' do
      user.update_columns(deleted_at: 5.days.ago)
      delete purge_admin_user_path(user.login)
      expect(User.with_deleted.exists?(user.id)).to be(true)
    end

    it 'refuses to purge a live (not soft-deleted) user' do
      delete purge_admin_user_path(user.login)
      expect(User.with_deleted.exists?(user.id)).to be(true)
    end

    it 'cascades to the user\'s tracks when purged' do
      asset_id = assets(:valid_arthur_mp3).id
      user.update_columns(deleted_at: 40.days.ago)
      delete purge_admin_user_path(user.login)
      expect(Asset.with_deleted.exists?(asset_id)).to be(false)
    end

    it 'removes relations that were already soft-deleted along with the user' do
      asset = assets(:valid_arthur_mp3)
      listen = asset.listens.create!(track_owner: user)
      UserCommand.new(user).soft_delete_with_relations
      user.update_columns(deleted_at: 40.days.ago)
      delete purge_admin_user_path(user.login)
      expect(User.with_deleted.exists?(user.id)).to be(false)
      expect(Asset.with_deleted.exists?(asset.id)).to be(false)
      expect(Listen.with_deleted.where(id: listen.id)).to be_empty
    end

    it 'decrements counters for surviving tracks the deleted user listened to' do
      listener = users(:aaron)
      asset = assets(:valid_mp3)
      owner = asset.user
      3.times { asset.listens.create!(listener: listener, track_owner: owner) }
      asset_listens_count = asset.reload.listens_count
      owner_listens_count = owner.reload.listens_count

      listener.update_columns(deleted_at: 40.days.ago)
      delete purge_admin_user_path(listener.login)

      expect(asset.reload.listens_count).to eq(asset_listens_count - 3)
      expect(owner.reload.listens_count).to eq(owner_listens_count - 3)
    end

    it 'purges and decrements the asset counter for a listen that has no track_owner' do
      deleted_user = users(:aaron)
      surviving_track = assets(:valid_mp3)
      listen = surviving_track.listens.create!(listener: deleted_user, track_owner: surviving_track.user)
      listen.update_columns(track_owner_id: nil)
      surviving_asset_count = surviving_track.reload.listens_count

      deleted_user.update_columns(deleted_at: 40.days.ago)
      delete purge_admin_user_path(deleted_user.login)

      expect(Listen.with_deleted.exists?(listen.id)).to be(false)
      expect(surviving_track.reload.listens_count).to eq(surviving_asset_count - 1)
    end

    it 'purges a user who has a patron record' do
      Patron.create!(user: user)
      user.update_columns(deleted_at: 40.days.ago)
      delete purge_admin_user_path(user.login)
      expect(User.with_deleted.exists?(user.id)).to be(false)
    end
  end

  describe 'purging an asset' do
    let(:asset) { assets(:valid_arthur_mp3) }

    it 'hard-deletes an asset soft-deleted more than 30 days ago' do
      asset.update_columns(deleted_at: 40.days.ago)
      expect do
        delete purge_admin_asset_path(asset.id)
      end.to change { Asset.with_deleted.exists?(asset.id) }.from(true).to(false)
    end

    it 'refuses to purge an asset soft-deleted less than 30 days ago' do
      asset.update_columns(deleted_at: 5.days.ago)
      delete purge_admin_asset_path(asset.id)
      expect(Asset.with_deleted.exists?(asset.id)).to be(true)
    end

    it 'refuses to purge a live (not soft-deleted) asset' do
      delete purge_admin_asset_path(asset.id)
      expect(Asset.with_deleted.exists?(asset.id)).to be(true)
    end

    it 'cascades to listens and tolerates a missing audio feature' do
      listen = asset.listens.create!(track_owner: asset.user)
      asset.audio_feature&.destroy
      asset.update_columns(deleted_at: 40.days.ago)
      delete purge_admin_asset_path(asset.id)
      expect(Asset.with_deleted.exists?(asset.id)).to be(false)
      expect(Listen.where(id: listen.id)).to be_empty
    end

    it 'decrements the owner counter cache when purging a deleted asset' do
      owner = asset.user
      3.times { asset.listens.create!(track_owner: owner) }
      owner_listens_count = owner.reload.listens_count

      asset.update_columns(deleted_at: 40.days.ago)
      delete purge_admin_asset_path(asset.id)

      expect(owner.reload.listens_count).to eq(owner_listens_count - 3)
    end
  end

  describe 'authorization' do
    it 'forbids non-moderators from purging' do
      create_user_session(users(:arthur))
      victim = users(:aaron)
      victim.update_columns(deleted_at: 40.days.ago)
      delete purge_admin_user_path(victim.login)
      expect(User.with_deleted.exists?(victim.id)).to be(true)
    end

    it 'forbids non-admin moderators from purging (hard delete is admin-only)' do
      create_user_session(users(:sandbags))
      victim = users(:aaron)
      victim.update_columns(deleted_at: 40.days.ago)
      delete purge_admin_user_path(victim.login)
      expect(User.with_deleted.exists?(victim.id)).to be(true)
    end
  end
end
