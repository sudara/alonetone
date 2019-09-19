require 'rails_helper'

RSpec.describe Admin::AssetsController, type: :request do
  before do
    create_user_session(users(:sudara))
  end

  describe "spam for individual assets" do
    let(:asset) { assets(:asset_with_relations_for_soft_delete) }

    before :each do
      akismet_stub_submit_spam
    end

    it "should mark asset as spam" do
      expect(asset.is_spam).to eq(false)
      put spam_admin_asset_path(asset.id)
      asset.reload
      expect(asset.is_spam).to eq(true)
    end

    it "should update RAKISMET" do
      expect(Rakismet).to receive(:akismet_call)
      put spam_admin_asset_path(asset.id)
    end

    it "should soft_delete asset" do
      akismet_stub_submit_spam
      expect {
        put spam_admin_asset_path(asset.id)
      }.to change(Asset, :count).by(-1)
    end

    it "should soft_delete asset's comments" do
      comment_count = asset.comments.count
      expect(comment_count).to be > 0
      expect {
        put spam_admin_asset_path(asset.id)
      }.to change(Comment, :count).by(-comment_count)
    end

    it "should not touch audio_feature" do
      expect(asset.audio_feature).not_to be_nil
      expect {
        put spam_admin_asset_path(asset.id)
      }.not_to change(AudioFeature, :count)
    end

    it "should soft_delete tracks" do
      tracks_count = asset.tracks.count
      expect(tracks_count).to be > 0
      expect {
        put spam_admin_asset_path(asset.id)
      }.to change(Track, :count).by(-tracks_count)
    end

    it "should cleanup any existing playlists" do
      playlist = asset.tracks.first.playlist
      playlist_tracks_count = playlist.tracks_count

      # make sure there are more than 0 tracks in that playlist
      expect(playlist_tracks_count).to be >= 1

      put spam_admin_asset_path(asset.id)
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
        put spam_admin_asset_path(asset.id)
      }.to change(Listen, :count).by(-listens_count)
    end

    it "should NOT touch users' listens_count unless we can prove that the listen was spammy" do
      user = asset.user
      user_listens_count = user.listens_count

      expect(user_listens_count).to be > 0

      put spam_admin_asset_path(asset.id)
      # 2 listens in listens.yml
      expect(user.reload.listens_count).to eq(user_listens_count)
    end
  end

  describe "unspam individual assets" do
    let(:track) { assets(:spam_track) }

    before do
      AssetCommand.new(track).soft_delete_with_relations
    end

    it "should unspam the track" do
      akismet_stub_submit_ham
      put unspam_admin_asset_path(track.id)
      expect(track.reload.is_spam).to eq(false)
    end

    it "should update RAKISMET" do
      expect(Rakismet).to receive(:akismet_call)
      put unspam_admin_asset_path(track.id)
    end

    # not including further specs since it's the same as in #restore
    it "should restore asset" do
      expect {
        put restore_admin_asset_path(track.id)
      }.to change(Asset, :count).by(1)
    end
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

  describe "#restore" do
    let(:asset) { assets(:asset_with_relations_for_soft_delete) }

    before do
      AssetCommand.new(asset).soft_delete_with_relations
    end

    it "should restore asset" do
      expect {
        put restore_admin_asset_path(asset.id)
      }.to change(Asset, :count).by(1)
    end

    it "should restore asset's comments" do
      expect {
        put restore_admin_asset_path(asset.id)
      }.to change(Comment, :count).by(2)
    end

    it "should restore tracks" do
      expect {
        put restore_admin_asset_path(asset.id)
      }.to change(Track, :count).by(1)
    end

    it "should cleanup any existing playlists" do
      put restore_admin_asset_path(asset.id)

      playlist = asset.tracks.first.playlist
      # confirm it now shows soft_deleted tracks
      expect(playlist.reload.tracks.count).to eq(1)
      # confirm it recalculated tracks_count
      expect(playlist.reload.tracks_count).to eq(1)
    end


    it "should restore listens" do
      expect {
        put restore_admin_asset_path(asset.id)
      }.to change(Listen, :count).by(2)
    end
  end

  describe '#index' do
    let(:soft_deleted_asset) { assets(:asset_with_relations_for_soft_delete) }
    let(:spam_track) { assets(:spam_track) }

    it 'returns list of all assets' do
      get admin_assets_path
      expect(response.body).to match(/Soft deleted asset/)
      expect(response.body).to match(/song6/)
    end

    it 'should only return spam assets if flag is passed' do
      get admin_assets_path(filter_by: :is_spam)
      expect(response.body).not_to match(/Soft deleted asset/)
      expect(response.body).to match(/song6/)
    end

    it 'should only return deleted assets if flag is passed' do
      get admin_assets_path(filter_by: :deleted)
      expect(response.body).to match(/Soft deleted asset/)
      expect(response.body).not_to match(/song6/)
    end
  end
end
