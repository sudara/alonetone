require 'rails_helper'

RSpec.describe Admin::AssetsController, type: :request do
  before do
    create_user_session(users(:sudara))
  end

  describe "#spam for individual assets" do
    let(:track) { assets(:valid_mp3) }

    it "should mark asset as spam" do
      akismet_stub_submit_spam
      expect(track.is_spam).to eq(false)
      put "/admin/assets/#{track.id}/spam"
      track.reload
      expect(track.is_spam).to eq(true)
    end

    it "should update RAKISMET" do
      expect(Rakismet).to receive(:akismet_call)
      put spam_admin_asset_path(track.id)
    end
  end

  describe "#unspam individual assets" do
    let(:track) { assets(:spam_track) }

    it "should unspam the track" do
      akismet_stub_submit_ham
      put unspam_admin_asset_path(track.id)
      expect(track.reload.is_spam).to eq(false)
    end

    it "should update RAKISMET" do
      expect(Rakismet).to receive(:akismet_call)
      put unspam_admin_asset_path(track.id)
    end
  end

  describe "mass spam update" do
    let(:track1) { assets(:valid_zip) }
    let(:track2) { assets(:invalid_file) }
    let(:track3) { assets(:spam_track) }

    it "should mark all assets as spam" do
      akismet_stub_submit_spam
      put(
        mark_group_as_spam_admin_assets_path,
        params: { mark_spam_by: { user_id: users(:sudara).id } }
      )

      expect(track1.is_spam).to eq(true)
      expect(track2.is_spam).to eq(true)
      expect(track3.is_spam).to eq(true)
    end

    # it "should update RAKISMET only for spam tracks" do
    #   expect(Rakismet).to receive(:akismet_call).twice
    #   put mark_group_as_spam_admin_assets_path, params: { mark_spam_by: { user_id: 1 } }
    # end
  end

  describe "#delete" do
    it "should soft delete asset" do
      expect{
        put delete_admin_asset_path(assets(:spam_track).id)
      }.to change(Asset, :count).by(-1)
    end

    it "should redirect admin to root_path" do
      put delete_admin_asset_path(assets(:spam_track).id)
      expect(response).to redirect_to(root_path)
    end

    it "soft deletes an asset" do
      put delete_admin_asset_path(assets(:spam_track).id)
      assets(:spam_track).reload
      expect(assets(:spam_track).deleted_at).not_to be_nil
    end
  end

  describe "#index" do
    before :each do
      # its permalink is song6
      assets(:spam_track).update(deleted_at: Time.now - 1.week)
    end

    it "does not include deleted assets" do
      get admin_assets_path
      expect(response.body).to match(/song1/)
      expect(response.body).not_to match(/song6/)
    end
  end
end
