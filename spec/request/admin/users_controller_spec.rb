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

    it "sets a flash confirming the unspam" do
      akismet_stub_submit_ham
      put unspam_admin_user_path(user.login)
      expect(flash[:ok]).to be_present
    end
  end

  describe '#spam' do
    before :each do
      users(:arthur).update(is_spam: false)
    end

    let!(:user) { users(:arthur) }

    it "should mark the user as spam" do
      akismet_stub_submit_spam
      put spam_admin_user_path(user.login)
      expect(user.reload.is_spam).to eq(true)
    end

    it "should soft-delete the user" do
      akismet_stub_submit_spam
      put spam_admin_user_path(user.login)
      expect(user.reload.deleted_at).to be_present
    end

    it "should update RAKISMET with updated information about user" do
      expect(Rakismet).to receive(:akismet_call)
      put spam_admin_user_path(user.login)
    end

    it "should render a turbo_stream replacing the user row" do
      akismet_stub_submit_spam
      put spam_admin_user_path(id: user.login, row: true), as: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(%(action="replace"))
      expect(response.body).to include(%(target="user_#{user.id}"))
    end

    it "redirects to the home page when the user is soft-deleted from their public page" do
      akismet_stub_submit_spam
      referer = user_home_url(user.login)
      put spam_admin_user_path(user.login), headers: { 'HTTP_REFERER' => referer }, as: :turbo_stream
      expect(response).to redirect_to(root_path)
      expect(response).to have_http_status(:see_other)
      expect(flash[:ok]).to be_present
    end

    it "redirects row-context non-stream requests to the admin index" do
      akismet_stub_submit_spam
      put spam_admin_user_path(id: user.login, row: true)
      expect(response).to redirect_to(admin_users_path(filter_by: :is_spam))
      expect(response).to have_http_status(:see_other)
    end
  end

  describe '#unspam redirect' do
    before :each do
      users(:arthur).update(is_spam: true)
      UserCommand.new(users(:arthur)).soft_delete_with_relations
    end

    it "redirects back to the referring page when the user is restored" do
      akismet_stub_submit_ham
      referer = admin_possibly_deleted_user_url(users(:arthur).login)
      put unspam_admin_user_path(users(:arthur).login), headers: { 'HTTP_REFERER' => referer }, as: :turbo_stream
      expect(response).to redirect_to(referer)
      expect(response).to have_http_status(:see_other)
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
      expect(users(:arthur).comments_received.count).to be > 0
    end

    it "should render a turbo_stream replacing the user row" do
      put restore_admin_user_path(id: users(:arthur).login, row: true), as: :turbo_stream
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(%(action="replace"))
      expect(response.body).to include(%(target="user_#{users(:arthur).id}"))
    end

    context "when the user was marked as spam" do
      before do
        users(:arthur).update_column(:is_spam, true)
      end

      it "also clears the spam flag" do
        akismet_stub_submit_ham
        put restore_admin_user_path(users(:arthur))
        expect(users(:arthur).reload.is_spam).to eq(false)
      end

      it "notifies Akismet that the user is ham" do
        expect(Rakismet).to receive(:akismet_call)
        put restore_admin_user_path(users(:arthur))
      end
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
      expect(response).to redirect_to(admin_users_path(filter_by: :deleted))
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

      put delete_admin_user_path(users(:arthur))

      users(:arthur).reload

      expect(users(:arthur).assets.count).to eq(0)
      expect(users(:arthur).tracks.count).to eq(0)
      expect(users(:arthur).listens.count).to eq(0)
      expect(users(:arthur).playlists.count).to eq(0)
      expect(users(:arthur).comments_received.count).to eq(0)
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
      expect(users(:henri_willig).comments_made.count).to eq(2)
      put delete_admin_user_path(users(:henri_willig))
      expect(users(:henri_willig).comments_made.count).to eq(0)
    end

    # `.user` is a receiver of a comment
    it "soft deleted comments received by others" do
      expect(users(:arthur).comments_received.count).to eq(7)
      put delete_admin_user_path(users(:arthur))
      expect(users(:arthur).comments_received.count).to eq(0)
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

    it "redirects to the home page when the user is deleted from their public page" do
      referer = user_home_url(users(:arthur).login)
      put delete_admin_user_path(users(:arthur).login), headers: { 'HTTP_REFERER' => referer }, as: :turbo_stream
      expect(response).to redirect_to(root_path)
      expect(response).to have_http_status(:see_other)
      expect(flash[:ok]).to be_present
    end
  end

  describe '#index' do
    before :each do
      users(:arthur).update(deleted_at: Time.now - 1.week)
      users(:aaron).update(is_spam: true)
    end

    context "if deleted: true flag is passed" do
      it "should return users with deleted" do
        get admin_users_path(filter_by: :deleted)
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
        get admin_users_path(filter_by: :is_spam)
        expect(response.body).to match(/aaron/)
        expect(response.body).not_to match(/arthur/)
        expect(response.body).not_to match(/ben/)
      end

      it "should return only non spam users if is_spam is set to false" do
        get admin_users_path(filter_by: :not_spam)
        expect(response.body).not_to match(/aaron/)
        expect(response.body).to match(/arthur/)
        expect(response.body).to match(/ben/)
      end
    end

    context "default params" do
      it "should not break if no filter_by is passed" do
        get admin_users_path
        expect(response.status).to eq(200)
        expect(response.body).to include('row=true')
      end
    end

    it "labels the shared-login-IP spam action as accounts and puts confirmation on the form" do
      users(:arthur).update!(deleted_at: nil, is_spam: false, current_login_ip: '203.0.113.8')
      users(:aaron).update!(is_spam: false, current_login_ip: '203.0.113.8')

      get admin_users_path

      doc = Nokogiri::HTML(response.body)
      form = doc.at_css('form[data-turbo-confirm*="Mark all 2 accounts"]')
      expect(form).to be_present
      expect(form.at_css('button[type="submit"]').text.strip).to eq('Spam all 2 accounts')
    end

    it "mutes spam rows without a danger border" do
      get admin_users_path(filter_by: :is_spam)

      doc = Nokogiri::HTML(response.body)
      row = doc.at_css("#user_#{users(:aaron).id}")
      expect(row['class']).not_to include('border-danger')
      expect(row.at_css('.opacity-70')).to be_present
      expect(row.text).to include('spam')
    end

    it "uses success styling for restore actions" do
      get admin_users_path(filter_by: :deleted)

      doc = Nokogiri::HTML(response.body)
      row = doc.at_css("#user_#{users(:arthur).id}")
      restore_button = row.css('button[type="submit"]').find { |b| b.text.strip == 'Restore' }
      expect(restore_button['class']).to include('bg-success')
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

      it 'links to the public profile' do
        expect(response.body).to include(user_home_path(users(:sudara)))
        expect(response.body).to include('public profile')
      end

      it 'should display users assets' do
        expect(response.body).to match(/Tracks/)
        expect(response.body).to match(/Very good song/)
      end

      it 'should display users comments' do
        expect(response.body).to match(/Comments/)
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
        expect(response.body).to match(/deleted/i)
      end

      it 'should display user information' do
        expect(response.body).to match(/arthur/)
      end

      it 'should display users assets' do
        expect(response.body).to match(/song1/)
      end
    end
  end
end
