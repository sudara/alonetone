require 'rails_helper'

RSpec.describe AssetNotificationJob, type: :job do
  describe "#upload_notification" do

    subject(:job) { described_class.perform_later( asset_ids: [assets(:valid_mp3).id], user_id: users(:arthur).id ) }

    it "sends a single notification" do
      job
      expect(AssetNotification).to receive(:upload_notification)
        .with(assets(:valid_mp3), users(:arthur).email)
        .and_call_original
      perform_enqueued_jobs
      expect(described_class).to(have_been_performed)
    end
  end

  describe "#upload_mass_notification" do
    subject(:job) { described_class.perform_later( asset_ids: [assets(:valid_mp3_2).id, assets(:valid_mp3).id], user_id: users(:arthur).id ) }

    it "sends a single notification" do
      job
      expect(AssetNotification).to receive(:upload_mass_notification)
        .with(a_collection_including(assets(:valid_mp3), assets(:valid_mp3_2)), users(:arthur).email)
        .and_call_original
      perform_enqueued_jobs
      expect(described_class).to(have_been_performed)
    end
  end

  describe "does not send notification" do
    subject(:job) { described_class.perform_later( asset_ids: [999999], user_id: 99999 ) }

    it "when assets not found" do
      job
      expect(AssetNotification).not_to receive(:upload_mass_notification)
      expect(AssetNotification).not_to receive(:upload_notification)
      perform_enqueued_jobs
      expect(described_class).to(have_been_performed)
    end

    it "when follower doesn't have an email" do
      users(:arthur).email = nil
      job
      expect(AssetNotification).not_to receive(:upload_mass_notification)
      expect(AssetNotification).not_to receive(:upload_notification)
      perform_enqueued_jobs
      expect(described_class).to(have_been_performed)
    end

    it "does not error if user not found" do
      expect{ job }.not_to raise_error
      perform_enqueued_jobs
      expect(described_class).to(have_been_performed)
    end
  end
end
