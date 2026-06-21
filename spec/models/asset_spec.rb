# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Asset, type: :model do
  it "supports characters outside of the basic multilingual plane in the title" do
    expect(Asset.new(title: '👍').title).to eq('👍')
  end

  it 'should use its permalink as param' do
    expect(assets(:will_studd_rockfort_combalou).permalink).to eq(
      assets(:will_studd_rockfort_combalou).to_param
    )
  end

  it 'keeps the old cron-facing purge method name as an alias' do
    expect(Asset.destroy_deleted_accounts_older_than_30_days(dry_run: true))
      .to eq(Asset.destroy_deleted_older_than_30_days(dry_run: true))
  end

  context "asset with audio file" do
    let(:asset) { assets(:will_studd_rockfort_combalou) }

    it "returns a signed location based on the audio file" do
      location = asset.download_location
      expect(location).to be_signed
      expect(location.attachment).to eq(asset.audio_file)
    end
  end

  describe 'scopes' do
    it 'include avatar image to prevent n+1 queries' do
      expect do
        Asset.with_preloads.each do |asset|
          asset.user.avatar_image
        end
      end.to perform_queries(count: 4)
    end

    context "user's assets" do
      let(:user) { users(:jamie_kiesl) }

      it "should order user's hottest tracks" do
        track_111 = assets(:valid_asset_to_test_on_latest)
        track_101 = assets(:another_valid_asset_to_test_on_latest)

        assert_equal [track_111, track_101], user.assets.hottest
      end

      it "should order user's most listened to tracks" do
        track_listen_5 = assets(:asset_with_relations_for_soft_delete)
        track_listen_2 = assets(:valid_asset_to_test_on_latest)
        track_listen_3 = assets(:another_valid_asset_to_test_on_latest)
        # 0 listens is not included
        track_listen_0 = assets(:jamie_kiesl_the_duck)

        assert_equal [track_listen_5, track_listen_3, track_listen_2], user.assets.most_listened
      end

      it "should order user's most commented tracks" do
        track_comment_4 = assets(:valid_asset_to_test_on_latest)
        track_comment_6 = assets(:another_valid_asset_to_test_on_latest)
        assert_equal [track_comment_6, track_comment_4], user.assets.most_commented
      end
    end
  end

  context "validation" do
    let(:mp3_asset) do
      Asset.new(
        user: users(:will_studd),
        audio_file: file_fixture_uploaded_file(
          'smallest.mp3', filename: 'smallest.mp3', content_type: 'audio/mpeg'
        )
      )
    end
    let(:zip_asset) do
      Asset.new(
        user: users(:will_studd),
        audio_file: file_fixture_uploaded_file(
          'smallest.zip', filename: 'smallest.zip', content_type: 'application/zip'
        )
      )
    end
    let(:binary_asset) do
      Asset.new(
        user: users(:will_studd),
        audio_file: file_fixture_uploaded_file(
          'smallest.zip', filename: 'smallest.zip', content_type: 'application/octet-stream'
        )
      )
    end
    let(:huge_asset) do
      Asset.new(
        user: users(:will_studd),
        audio_file: file_fixture_uploaded_file(
          'smallest.mp3', filename: 'smallest.mp3', content_type: 'audio/mpeg'
        )
      )
    end

    it "can be an mp3 file" do
      expect(mp3_asset).to be_valid
    end

    it "cannot be a zip file" do
      expect(zip_asset).not_to be_valid
      expect(zip_asset.errors[:audio_file]).to_not be_empty
    end

    it "cannot be an unknown file" do
      expect(binary_asset).not_to be_valid
      expect(binary_asset.errors[:audio_file]).to_not be_empty
    end

    it "cannot be larger than 60 megabytes" do
      huge_asset.audio_file.byte_size = 230.megabytes
      expect(huge_asset).not_to be_valid
      expect(huge_asset.errors[:audio_file]).to_not be_empty
    end
  end

  context "mp3 tags" do
    it "should use tag2 TT2 as name if present" do
      asset = file_fixture_asset('muppets.mp3', content_type: 'audio/mpeg')
      expect(asset.name).to eq('Old Muppet Men Booing')
    end

    it "should still work even when tags are empty and the name is weird" do
      asset = file_fixture_asset('_ .mp3', content_type: 'audio/mpeg')
      expect(asset.permalink).to eq('_')
      expect(asset.title).to eq('_')
      expect(asset.name).to eq('_')
    end

    it "should handle strange charsets / characters in title tags" do
      asset = file_fixture_asset('japanese-characters.mp3', content_type: 'audio/mpeg')
      expect(asset.title).to eq('01-¶ÔμÄÈË') # name is still 01-\266Ե??\313"
      expect(asset.name).to eq('01-¶ÔμÄÈË') # name is still 01-\266Ե??\313"
      expect(asset.mp3_file_name).to eq('japanese-characters.mp3')
    end

    it "should cope with non-english filenames" do
      asset = file_fixture_asset('中文測試.mp3', content_type: 'audio/mpeg')
      expect(asset.save).to eq(true)
      asset.mp3_file_name == '中文測試.mp3'
    end

    it "should handle umlauts and non english characters in the filename" do
      filename = 'müppets.mp3'
      asset = file_fixture_asset(
        'muppets.mp3',
        filename: filename,
        content_type: 'audio/mpeg'
      )
      expect(asset.mp3_file_name).to eq(filename)
    end

    it 'creates an asset with a Chinese title in the ID3 tags' do
      asset = file_fixture_asset('中文測試.mp3', content_type: 'audio/mpeg')
      expect(asset).to be_persisted
      expect(asset.name).to eq("中文測試")
      expect(asset.title).to eq("中文測試")
      expect(asset.permalink).not_to be_blank
      expect(asset.permalink).to eq("中文測試")
    end

    it "should use the mp3 tag1 title as name if present" do
      asset = file_fixture_asset('tag1.mp3', content_type: 'audio/mpeg')
      expect(asset.name).to eq("Mark S Williams")
    end

    it "should use the filename as name if no tags are present" do
      asset = file_fixture_asset('titleless.mp3', content_type: 'audio/mpeg')
      expect(asset.name).to eq('titleless')
    end

    it "should generate a permalink from tags" do
      asset = file_fixture_asset('tag2.mp3', content_type: 'audio/mpeg')
      expect(asset.permalink).to eq('put-a-nickel-on-my-door')
    end

    it "should generate unique permalinks" do
      asset = file_fixture_asset('tag2.mp3', content_type: 'audio/mpeg')
      asset2 = file_fixture_asset('tag2.mp3', content_type: 'audio/mpeg')
      expect(asset2.permalink).to eq('put-a-nickel-on-my-door-2')
    end

    it "should make sure to grab bitrate and length in seconds" do
      asset = file_fixture_asset('muppets.mp3', content_type: 'audio/mpeg')
      expect(asset.bitrate).to eq(192)
      expect(asset.length).to eq('0:13')
    end

    describe "#publish" do
      it "should update private false to true" do
        asset = assets(:private_track)
        asset.publish!
        asset.reload
        expect(asset.private).to eq(false)
      end
    end
  end

  context "creation" do
    let(:user) { users(:will_studd) }

    it "schedules a job to create a waveform" do
      expect do
        user.assets.create!(
          title: 'Smallest',
          audio_file: fixture_file_upload('smallest.mp3', 'audio/mpeg')
        )
      end.to have_enqueued_job(WaveformExtractJob)
    end

    it "does not create with an empty MP3" do
      asset = user.assets.create(
        title: 'Empty',
        audio_file: fixture_file_upload('empty.mp3', 'audio/mpeg')
      )
      expect(asset.errors).to_not be_empty
    end

    it "increments the user's counter" do
      expect {
        user.assets.create(
          title: 'Smallest',
          audio_file: fixture_file_upload('smallest.mp3', 'audio/mpeg')
        )
      }.to change { user.reload.assets_count }.by(1)
    end

    it "updates the user's last uploaded timestamp" do
      user.update!(last_uploaded_at: 1.year.ago)

      travel_to Time.current.change(usec: 0) do
        asset = user.assets.create!(
          title: 'Smallest',
          audio_file: fixture_file_upload('smallest.mp3', 'audio/mpeg')
        )

        expect(user.reload.last_uploaded_at.to_i).to eq(asset.created_at.to_i)
      end
    end
  end

  describe '#recent_listeners' do
    let(:asset) { assets(:valid_mp3) }

    it 'returns listeners by their most recent listen' do
      old_listener = users(:arthur)
      recent_listener = users(:sudara)

      Listen.create!(
        asset: asset,
        listener: old_listener,
        track_owner: asset.user,
        created_at: 3.days.ago
      )
      Listen.create!(
        asset: asset,
        listener: recent_listener,
        track_owner: asset.user,
        created_at: 1.day.ago
      )

      expect(asset.recent_listeners(limit: 2).to_a).to eq(
        [recent_listener, old_listener]
      )
    end

    it 'returns each listener once' do
      listener = users(:arthur)

      2.times do |offset|
        Listen.create!(
          asset: asset,
          listener: listener,
          track_owner: asset.user,
          created_at: offset.hours.ago
        )
      end

      expect(asset.recent_listeners(limit: 6).to_a.count(listener)).to eq(1)
    end

    it 'ignores soft-deleted users' do
      deleted_user = users(:deleted_yesterday)

      Listen.create!(
        asset: asset,
        listener: deleted_user,
        track_owner: asset.user,
        created_at: 1.hour.ago
      )

      expect(asset.recent_listeners(limit: 6)).not_to include(deleted_user)
    end
  end

  context "on update" do
    it "should regenerate a permalink after the title is changed" do
      asset = file_fixture_asset('muppets.mp3', content_type: 'audio/mpeg')
      asset.title = 'New Muppets 123'
      asset.save
      expect(asset.permalink).to eq('new-muppets-123')
    end
  end

  describe 'audio features' do
    let(:asset) { assets(:will_studd_appellation_controlee) }
    let(:uploaded_file) { file_fixture_uploaded_file('piano.mp3') }
    let(:asset_filename) { uploaded_file.path }

    before do
      asset.audio_file.upload(uploaded_file)
    end

    context 'asset without audio feature' do
      before do
        asset.audio_feature.delete
        asset.association(:audio_feature).reset
      end

      it 'creates a new audio feature with a waveform' do
        asset.import_waveform
        asset.reload
        expect(asset.audio_feature.waveform).to eq(
          Waveform.extract(asset_filename)
        )
      end
    end

    context 'asset with audio feature' do
      it 'updates existing audio feature with a waveform' do
        asset.import_waveform
        asset.reload
        expect(asset.audio_feature.waveform).to eq(
          Waveform.extract(asset_filename)
        )
      end
    end
  end

  describe "soft deletion" do
    it "soft deletes and leaves the record in the database" do
      expect {
        Asset.all.map(&:soft_delete)
      }.not_to change { Asset.unscoped.count }
    end

    it "renders the record unavailable in the default scope" do
      original_count = Asset.count
      expect {
        Asset.all.map(&:soft_delete)
      }.to change { Asset.count }.from(original_count).to(0)
    end

    it "decrements the user counter cache on soft delete" do
      user = users(:arthur)
      expect {
        AssetCommand.new(assets(:valid_arthur_mp3)).soft_delete_with_relations
      }.to change { user.reload.assets_count }.by(-1)
    end

    it "refreshes the user's last uploaded timestamp on soft delete" do
      user = users(:jamie_kiesl)
      latest_asset = assets(:valid_asset_to_test_on_latest)
      previous_asset = assets(:another_valid_asset_to_test_on_latest)
      user.refresh_last_uploaded_at!

      expect {
        AssetCommand.new(latest_asset).soft_delete_with_relations
      }.to change { user.reload.last_uploaded_at.to_i }
        .from(latest_asset.created_at.to_i)
        .to(previous_asset.created_at.to_i)
    end

    it "touches the user on soft delete to expire user-level track caches" do
      user = users(:arthur)
      original_updated_at = user.updated_at

      travel_to(1.second.from_now) do
        AssetCommand.new(assets(:valid_arthur_mp3)).soft_delete_with_relations
      end

      expect(user.reload.updated_at).to be > original_updated_at
    end

    it "increments the user counter cache on restore" do
      user = users(:arthur)
      AssetCommand.new(assets(:valid_arthur_mp3)).soft_delete_with_relations
      expect {
        AssetCommand.new(assets(:valid_arthur_mp3)).restore_with_relations
      }.to change { user.reload.assets_count }.by(1)
    end

    it "refreshes the user's last uploaded timestamp on restore" do
      user = users(:jamie_kiesl)
      latest_asset = assets(:valid_asset_to_test_on_latest)
      previous_asset = assets(:another_valid_asset_to_test_on_latest)
      user.refresh_last_uploaded_at!
      AssetCommand.new(latest_asset).soft_delete_with_relations

      expect {
        AssetCommand.new(latest_asset).restore_with_relations
      }.to change { user.reload.last_uploaded_at.to_i }
        .from(previous_asset.created_at.to_i)
        .to(latest_asset.created_at.to_i)
    end

    it "touches the user on restore to expire user-level track caches" do
      user = users(:arthur)
      AssetCommand.new(assets(:valid_arthur_mp3)).soft_delete_with_relations
      user.reload
      original_updated_at = user.updated_at

      travel_to(1.second.from_now) do
        AssetCommand.new(assets(:valid_arthur_mp3)).restore_with_relations
      end

      expect(user.reload.updated_at).to be > original_updated_at
    end
  end

  describe "hard deletion" do
    it "doesn't decrement the user counter cache on hard delete, as its already decremented" do
      user = users(:arthur)
      AssetCommand.new(assets(:valid_arthur_mp3)).soft_delete_with_relations
      user.reload
      expect {
        assets(:valid_arthur_mp3).destroy
      }.not_to change { user.reload.assets_count }
    end
  end

  # ensure that we still allow access to a user record
  # even if it's been soft_deleted
  describe 'belongs_to possibly_deleted_user' do
    let(:asset) { assets(:soft_deleted_asset_with_soft_deleted_user) }

    it 'allows access to soft_deleted user' do
      expect(asset.soft_deleted?).to eq(true)
      expect(asset.user).to be_nil
      expect(asset.possibly_deleted_user).not_to be_nil
    end
  end

  describe 'slug' do
    let(:title) { 'Music for the Masses' }
    let(:slug) { Slug.generate(title) }
    let(:audio_file) do
      file_fixture_uploaded_file(
        'smallest.mp3', filename: 'smallest.mp3', content_type: 'audio/mpeg'
      )
    end

    it 'updates when the name changes' do
      asset = Asset.new(title: title)
      expect(asset.permalink).to eq(slug)
    end

    it 'saves the permalink after creation' do
      asset = Asset.create!(user: users(:henri_willig), title: title, audio_file: audio_file)
      expect(asset.reload.permalink).to eq(slug)
    end

    it 'updates after title update' do
      asset = assets(:henri_willig_finest_cheese)
      asset.update(title: title)
      expect(asset.reload.permalink).to eq(slug)
    end

    it 'increments the slug in case of a collision' do
      existing = assets(:henri_willig_finest_cheese)
      asset = Asset.create!(
        user: users(:henri_willig), title: existing.title, audio_file: audio_file
      )
      expect(asset.reload.permalink).to eq('manufacturer-of-the-finest-cheese-2')
    end
  end
end
