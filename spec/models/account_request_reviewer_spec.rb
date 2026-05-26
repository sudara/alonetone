require 'rails_helper'

RSpec.describe AccountRequestReviewer, type: :model do
  let(:account_request) do
    AccountRequest.create!(
      login: "testmusician",
      email: "test@example.com",
      entity_type: :musician,
      details: "I play guitar and write songs, here's my bandcamp: https://test.bandcamp.com",
      remote_ip: "1.2.3.4"
    )
  end

  describe "#review" do
    it "returns flag when API key is not configured" do
      result = described_class.new(account_request).review
      expect(result.decision).to eq("flag")
      expect(result.reason).to eq("Auto-review not configured")
    end

    it "returns flag when the prompt is not configured" do
      allow(Rails.configuration.alonetone).to receive(:anthropic_api_key).and_return("sk-test")
      allow(Rails.configuration.alonetone).to receive(:account_review_model).and_return("claude-test")
      allow(Rails.configuration.alonetone).to receive(:account_review_prompt).and_return(nil)
      result = described_class.new(account_request).review
      expect(result.decision).to eq("flag")
      expect(result.reason).to eq("Auto-review not configured")
    end

    it "returns flag when the model is not configured" do
      allow(Rails.configuration.alonetone).to receive(:anthropic_api_key).and_return("sk-test")
      allow(Rails.configuration.alonetone).to receive(:account_review_model).and_return(nil)
      allow(Rails.configuration.alonetone).to receive(:account_review_prompt).and_return("Review this.")
      result = described_class.new(account_request).review
      expect(result.decision).to eq("flag")
      expect(result.reason).to eq("Auto-review not configured")
    end

    context "with API configured" do
      before do
        allow(Rails.configuration.alonetone).to receive(:anthropic_api_key).and_return("sk-test")
        allow(Rails.configuration.alonetone).to receive(:account_review_prompt).and_return("Review this.")
        allow(Rails.configuration.alonetone).to receive(:account_review_model).and_return("claude-test")
      end

      it "returns approve for a legitimate musician" do
        stub_anthropic_response(decision: "approve", reason: "Musician with bandcamp link")
        result = described_class.new(account_request).review
        expect(result.decision).to eq("approve")
        expect(result.reason).to eq("Musician with bandcamp link")
      end

      it "returns deny for spam" do
        stub_anthropic_response(decision: "deny", reason: "Business promotion, not a musician")
        result = described_class.new(account_request).review
        expect(result.decision).to eq("deny")
      end

      it "returns flag on API failure" do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 500, body: "Internal Server Error")
        result = described_class.new(account_request).review
        expect(result.decision).to eq("flag")
        expect(result.reason).to include("Automated review unavailable")
      end

      it "returns alert status without sending mail on auth or billing failure" do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(status: 429, body: "Out of credits")

        result = nil
        expect {
          result = described_class.new(account_request).review
        }.not_to change(ActionMailer::Base.deliveries, :count)

        expect(result.decision).to eq("flag")
        expect(result.alert_status_code).to eq("429")
      end

      it "returns flag on network timeout" do
        stub_request(:post, "https://api.anthropic.com/v1/messages").to_timeout
        result = described_class.new(account_request).review
        expect(result.decision).to eq("flag")
      end

      it "summarizes integer enum status keys as names" do
        summary = described_class.new(account_request).send(
          :summarize_status_counts,
          { 1 => 2, "denied" => 1 },
          none: "none"
        )
        expect(summary).to eq("2 approved, 1 denied")
      end
    end
  end

  def stub_anthropic_response(decision:, reason:)
    body = {
      content: [{ type: "text", text: JSON.generate(decision: decision, reason: reason) }]
    }
    stub_request(:post, "https://api.anthropic.com/v1/messages")
      .to_return(status: 200, body: JSON.generate(body), headers: { "content-type" => "application/json" })
  end
end
