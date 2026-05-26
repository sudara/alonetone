require 'rails_helper'

RSpec.describe ReviewAccountRequestJob, type: :job do
  let(:account_request) do
    AccountRequest.create!(
      login: "testmusician",
      email: "test@example.com",
      entity_type: :musician,
      details: "I play guitar and write songs, here's my bandcamp: https://test.bandcamp.com",
      remote_ip: "1.2.3.4"
    )
  end

  it "skips if account request no longer exists" do
    expect { described_class.perform_now(-1) }.not_to raise_error
  end

  it "skips if account request is no longer waiting" do
    account_request.denied!
    expect(AccountRequestReviewer).not_to receive(:new)
    described_class.perform_now(account_request.id)
  end

  context "when review returns approve" do
    before do
      allow_any_instance_of(AccountRequestReviewer).to receive(:review)
        .and_return(AccountRequestReviewer::Result.new(decision: "approve", reason: "Legit musician"))
    end

    it "auto-approves and creates a user" do
      expect { described_class.perform_now(account_request.id) }
        .to change(User, :count).by(1)
      expect(account_request.reload).to be_approved
      expect(account_request.review_reason).to eq("Anthropic: Legit musician")
    end

    it "sends the applicant approval email and mod notification" do
      expect { described_class.perform_now(account_request.id) }
        .to change(ActionMailer::Base.deliveries, :count).by(2)
    end
  end

  context "when review returns deny" do
    before do
      allow_any_instance_of(AccountRequestReviewer).to receive(:review)
        .and_return(AccountRequestReviewer::Result.new(decision: "deny", reason: "Spam business"))
    end

    it "denies the request" do
      described_class.perform_now(account_request.id)
      expect(account_request.reload).to be_denied
      expect(account_request.review_reason).to eq("Anthropic: Spam business")
    end

    it "schedules the weekly denied digest" do
      expect(WeeklyDeniedDigestJob).to receive(:schedule_next)
      described_class.perform_now(account_request.id)
    end

    it "does not create a user" do
      expect { described_class.perform_now(account_request.id) }
        .not_to change(User, :count)
    end
  end

  context "when review returns flag" do
    before do
      allow_any_instance_of(AccountRequestReviewer).to receive(:review)
        .and_return(AccountRequestReviewer::Result.new(decision: "flag", reason: "Unsure, needs human review"))
    end

    it "leaves the request as waiting with the reason stored" do
      described_class.perform_now(account_request.id)
      expect(account_request.reload).to be_waiting
      expect(account_request.review_reason).to eq("Anthropic: Unsure, needs human review")
    end

    it "sends a mod notification" do
      expect { described_class.perform_now(account_request.id) }
        .to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  context "when review reports an API billing alert" do
    before do
      allow_any_instance_of(AccountRequestReviewer).to receive(:review)
        .and_return(
          AccountRequestReviewer::Result.new(
            decision: "flag",
            reason: "Automated review unavailable, needs human review",
            alert_status_code: "429"
          )
        )
    end

    it "sends the billing alert from the job" do
      expect { described_class.perform_now(account_request.id) }
        .to change(ActionMailer::Base.deliveries, :count).by(2)
      expect(ActionMailer::Base.deliveries.map(&:subject))
        .to include("[alonetone.example.com] Signup auto-review is down (API 429)")
    end
  end
end
