require 'rails_helper'

RSpec.describe WeeklyDeniedDigestJob, type: :job do
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

  it "does not send when there are no auto-denied requests" do
    expect { described_class.perform_now }
      .not_to change(ActionMailer::Base.deliveries, :count)
  end
end
