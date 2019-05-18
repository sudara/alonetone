require 'rails_helper'

RSpec.describe Admin::AssetsController, type: :request do
  before do
    create_user_session(users(:sudara))
  end

  describe '#unspam' do
    before :each do
      users(:arthur).update(is_spam: true)
    end

    let!(:user) { users(:arthur) }

    it "should unspam the user" do
      akismet_stub_submit_ham
      put unspam_admin_user_path(user.login)
      expect(user.reload.is_spam).to eq(false)
    end

    it "should update RAKISMET with updated information about user" do
      expect(Rakismet).to receive(:akismet_call)
      put unspam_admin_user_path(user.login)
    end
  end

  describe '#spam' do
    before :each do
      users(:arthur).update(is_spam: false)
    end

    let!(:user) { users(:arthur) }

    it "should unspam the user" do
      akismet_stub_submit_spam
      put spam_admin_user_path(user.login)
      expect(user.reload.is_spam).to eq(true)
    end

    it "should update RAKISMET with updated information about user" do
      expect(Rakismet).to receive(:akismet_call)
      put spam_admin_user_path(user.login)
    end
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

  describe '#index' do
    before :each do
      users(:arthur).update(deleted_at: Time.now - 1.week)
      users(:aaron).update(is_spam: true)
    end

    context "if deleted: true flag is passed" do
      it "should return users with deleted" do
        get admin_users_path(deleted: true)
        expect(response.body).to match(/arthur/)
        expect(response.body).not_to match(/ben/)
      end
    end

    context "if deleted: flag is not passed" do
      it "should return users count without deleted if" do
        get admin_users_path
        expect(response.body).to match(/arthur/)
        expect(response.body).to match(/sudara/)
      end
    end

    context "with filter_by" do
      it "should return spam users only if flag is passed" do
        get admin_users_path({filter_by: { is_spam: true}})
        expect(response.body).to match(/aaron/)
        expect(response.body).not_to match(/arthur/)
        expect(response.body).not_to match(/ben/)
      end

      it "should return only non spam users if is_spam is set to false" do
        get admin_users_path({filter_by: { is_spam: false}})
        expect(response.body).not_to match(/aaron/)
        expect(response.body).to match(/arthur/)
        expect(response.body).to match(/ben/)
      end
    end

    context "default params" do
      it "should not break if no filter_by is passed" do
        get admin_users_path
        expect(response.status).to eq(200)
      end
    end
  end
end