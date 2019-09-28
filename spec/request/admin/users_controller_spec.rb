require 'rails_helper'

RSpec.describe Admin::UsersController, type: :request do
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
      UserCommand.new(users(:arthur)).soft_delete_with_relations
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
      expect(response).to redirect_to(admin_users_path({ filter_by: :deleted }))
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

    it "soft deletes from other user's playlist" do
      # sudara's playlist
      playlists(:owp)
      # arthur's track on owp playlist
      tracks(:sudaras_track_with_asset_on_other_user)

      put delete_admin_user_path(users(:arthur))

      expect(tracks(:sudaras_track_with_asset_on_other_user).reload.deleted_at).not_to be_nil
    end

    # `.commenter` is the giver of comments
    it "soft deletes comments given to others" do
      expect(Comment.where(commenter_id: users(:arthur).id).count).to eq(4)
      expect(users(:arthur).given_comments.count).to eq(4)
      put delete_admin_user_path(users(:arthur))
      expect(users(:arthur).given_comments.count).to eq(0)
    end

    # `.user` is a receiver of a comment
    it "soft deleted comments received by others" do
      expect(Comment.where(user_id: users(:arthur).id).count).to eq(1)
      expect(users(:arthur).comments.count).to eq(1)
      put delete_admin_user_path(users(:arthur))
      expect(users(:arthur).comments.count).to eq(0)
    end

    it "soft deletes comments on user's asset by others" do
      # arthurs asset
      asset = assets(:valid_arthur_mp3)
      # comment made by sudara on arthur's comment
      comment = comments(:public_comment_soft_deletion_relations)
      expect(comment.user_id).to eq(users(:arthur).id)
      expect(comment.commenter_id).to eq(users(:sudara).id)

      put delete_admin_user_path(users(:arthur))
      expect(comment.reload.deleted_at).not_to be_nil
    end
  end

  describe '#index' do
    before :each do
      users(:arthur).update(deleted_at: Time.now - 1.week)
      users(:aaron).update(is_spam: true)
    end

    context "if deleted: true flag is passed" do
      it "should return users with deleted" do
        get admin_users_path({ filter_by: :deleted })
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
        get admin_users_path({ filter_by: :is_spam })
        expect(response.body).to match(/aaron/)
        expect(response.body).not_to match(/arthur/)
        expect(response.body).not_to match(/ben/)
      end

      it "should return only non spam users if is_spam is set to false" do
        get admin_users_path({ filter_by: :not_spam })
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

  describe '#show' do
    context 'non deleted user' do
      before :each do
        get admin_possibly_deleted_user_path(users(:sudara).login)
      end

      it 'should display user information' do
        expect(response.body).to match(/sudara/)
      end

      it 'should display users assets' do
        expect(response.body).to match(/User's Tracks/)
        expect(response.body).to match(/Very good song/)
      end

      it 'should display users comments' do
        expect(response.body).to match(/User's Comments/)
        expect(response.body).to match(/this is an awesome track, says a user/)
      end
    end

    context 'soft_deleted user' do
      before do
        UserCommand.new(users(:arthur)).soft_delete_with_relations
      end

      before :each do
        get admin_possibly_deleted_user_path('arthur')
      end

      it 'should display deleted at date' do
        expect(response.body).to match(/Deleted/)
      end

      it 'should display user information' do
        expect(response.body).to match(/arthur/)
      end

      it 'should display users assets' do
        expect(response.body).to match(/song1/)
      end

      it 'should display users comments' do
        expect(response.body).to match(/forget milk./)
        expect(response.body).to match(/Well friend, this is your best work./)
      end
    end
  end
end
