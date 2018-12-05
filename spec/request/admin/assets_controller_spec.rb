require 'rails_helper'

RSpec.describe Admin::AssetsController, type: :request do
  fixtures :assets, :users

  before do
    create_user_session(users(:sudara))
  end

  describe "spam for individual assets" do
    let(:track) { assets(:valid_mp3) }

    it "should mark asset as spam" do
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

  describe "unspam individual assets" do
    let(:track) { assets(:spam_track) }

    it "should unspam the comment" do
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
      put mark_group_as_spam_admin_assets_path, params: { mark_spam_by: { user_id: 1 } }

      expect(track1.is_spam).to eq(true)
      expect(track2.is_spam).to eq(true)
      expect(track3.is_spam).to eq(true)
    end

    # it "should update RAKISMET only for spam tracks" do
    #   expect(Rakismet).to receive(:akismet_call).twice
    #   put mark_group_as_spam_admin_assets_path, params: { mark_spam_by: { user_id: 1 } }
    # end
  end
end
