require 'rails_helper'

RSpec.describe Admin::AssetsController, type: :request do
  before do
    create_user_session(users(:sudara))
  end

  describe "spam for individual assets" do
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

  describe "unspam individual assets" do
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
    let(:asset) { assets(:asset_with_relations_for_soft_delete) }

    it "should soft_delete asset" do
      expect {
        put delete_admin_asset_path(asset.id)
      }.to change(Asset, :count).by(-1)
    end

    it "should soft_delete asset's comments" do
      comment_count = asset.comments.count
      expect(comment_count).to be > 0
      expect {
        put delete_admin_asset_path(asset.id)
      }.to change(Comment, :count).by(-comment_count)
    end

    it "should not touch audio_feature" do
      expect(asset.audio_feature).not_to be_nil
      expect {
        put delete_admin_asset_path(asset.id)
      }.not_to change(AudioFeature, :count)
    end

    it "should soft_delete tracks" do
      tracks_count = asset.tracks.count
      expect(tracks_count).to be > 0
      expect {
        put delete_admin_asset_path(asset.id)
      }.to change(Track, :count).by(-tracks_count)
    end

    it "should cleanup any existing playlists" do
      playlist = asset.tracks.first.playlist
      playlist_tracks_count = playlist.tracks_count

      # make sure there are more than 0 tracks in that playlist
      expect(playlist_tracks_count).to be >= 1

      put delete_admin_asset_path(asset.id)
      # confirm it no longer shows soft_deleted tracks
      expect(playlist.reload.tracks.count).to eq(playlist_tracks_count - 1)
      # confirm it recalculated tracks_count
      expect(playlist.reload.tracks_count).to eq(playlist_tracks_count - 1)
    end


    it "should soft_delete listens" do
      listens_count = asset.listens.count
      # make sure there are more than 0 listens for that asset
      expect(listens_count).to be > 0

      expect {
        put delete_admin_asset_path(asset.id)
      }.to change(Listen, :count).by(-listens_count)
    end

    it "should NOT touch users' listens_count unless we can prove that the listen was spammy" do
      user = asset.user
      user_listens_count = user.listens_count

      expect(user_listens_count).to be > 0

      put delete_admin_asset_path(asset.id)
      # 2 listens in listens.yml
      expect(user.reload.listens_count).to eq(user_listens_count)
    end
  end
end
