require 'rails_helper'

RSpec.describe WeeklyDeniedDigestJob, type: :job do
  around do |example|
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = original_cache
  end

  describe ".schedule_next" do
    it "enqueues one digest for the next run window" do
      travel_to Time.zone.local(2026, 5, 26, 12) do
        run_at = described_class.next_run_at
        expect { described_class.schedule_next }
          .to have_enqueued_job(described_class).at(run_at).with(run_at.to_date.iso8601)
        expect { described_class.schedule_next }.not_to have_enqueued_job(described_class)
      end
    end
  end

  describe ".next_run_at" do
    it "uses the upcoming Monday morning before the weekly run has passed" do
      travel_to Time.zone.local(2026, 5, 25, 8) do
        expect(described_class.next_run_at).to eq(Time.zone.local(2026, 5, 25, 9))
      end
    end

    it "uses the following Monday after the weekly run has passed" do
      travel_to Time.zone.local(2026, 5, 25, 10) do
        expect(described_class.next_run_at).to eq(Time.zone.local(2026, 6, 1, 9))
      end
    end
  end

  describe "#perform" do
    it "sends a digest for recently auto-denied requests" do
      AccountRequest.create!(
        login: "digestspammer",
        email: "digest-spammer@example.com",
        entity_type: :musician,
        details: "This request has enough text to pass validation and then be denied."
      ).denied!

      expect { described_class.perform_now }
        .to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it "clears the scheduled cache key" do
      run_at = described_class.next_run_at
      Rails.cache.write(described_class.cache_key_for(run_at), true)

      described_class.perform_now(run_at.to_date.iso8601)

      expect(Rails.cache.exist?(described_class.cache_key_for(run_at))).to be(false)
    end
  end
end
