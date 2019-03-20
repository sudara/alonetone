require 'rails_helper'

RSpec.describe Admin::AssetsController, type: :request do
  before do
    create_user_session(users(:sudara))
  end

  describe '#restore' do
    before :each do
      users(:arthur).soft_delete_relations
      users(:arthur).update(deleted_at: Time.now - 1.week)

    end

    it "should restore a user" do
      expect {
        put restore_admin_user_path(users(:arthur))
      }.to change(User, :count).by(1)
    end

    it "should set deleted_at to nil" do
      put restore_admin_user_path(users(:arthur))
      expect(users(:arthur).reload.deleted_at).to be_nil
    end

    it "should restore users relations" do
      put restore_admin_user_path(users(:arthur))

      users(:arthur).reload

      expect(users(:arthur).assets.count).to be > 0
      expect(users(:arthur).tracks.count).to be > 0
      expect(users(:arthur).listens.count).to be > 0
      expect(users(:arthur).playlists.count).to be > 0
      expect(users(:arthur).topics.count).to eq(0)
      expect(users(:arthur).comments.count).to be > 0
    end
  end

  describe '#delete' do
    it "should delete a user" do
      expect {
        put delete_admin_user_path(users(:arthur))
      }.to change(User, :count).by(-1)
    end

    it "should redirect admin to root_path" do
      put delete_admin_user_path(users(:arthur))
      expect(response).to redirect_to(root_path)
    end

    it "sets deleted_at to true" do
      put delete_admin_user_path(users(:arthur))
      users(:arthur).reload
      expect(users(:arthur).deleted_at).not_to be_nil
    end

    it "soft deletes all associated records" do
      expect(users(:arthur).assets.count).to be > 0
      expect(users(:arthur).tracks.count).to be > 0
      expect(users(:arthur).listens.count).to be > 0
      expect(users(:arthur).playlists.count).to be > 0
      expect(users(:arthur).topics.count).to be > 0
      expect(users(:arthur).topics.count).to be > 0

      put delete_admin_user_path(users(:arthur))

      users(:arthur).reload

      expect(users(:arthur).assets.count).to eq(0)
      expect(users(:arthur).tracks.count).to eq(0)
      expect(users(:arthur).listens.count).to eq(0)
      expect(users(:arthur).playlists.count).to eq(0)
      expect(users(:arthur).topics.count).to eq(0)
      expect(users(:arthur).comments.count).to eq(0)
    end

    it "enqueues a job to really destroy the record" do
      put delete_admin_user_path(users(:arthur))
      expect(enqueued_jobs.size).to eq 1
      expect(enqueued_jobs.first[:queue]).to eq "default"
      expect(enqueued_jobs.last[:job]).to eq DeletedUserCleanupJob
    end
  end
end