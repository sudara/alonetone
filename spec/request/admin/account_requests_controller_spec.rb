require 'rails_helper'

RSpec.describe Admin::AccountRequestsController, type: :request do
  before do
    create_user_session(users(:sudara))
  end

  it "should allow moderators to approve a request" do
    put approve_admin_account_request_path(account_requests(:waiting))
    expect(response).to redirect_to(admin_account_requests_path)
    expect(account_requests(:waiting).reload.status).to eq('approved')
  end

  it "should send an email when a request is approved" do
    expect {
      put approve_admin_account_request_path(account_requests(:waiting))
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end

  it "should allow moderators to deny a request" do
    put deny_admin_account_request_path(account_requests(:waiting))
    expect(response).to redirect_to(admin_account_requests_path)
    expect(account_requests(:waiting).reload.status).to eq('denied')
  end

  it "shows the stored review reason" do
    account_requests(:waiting).update!(
      status: :denied,
      review_reason: "Rakismet marked as spam"
    )
    get admin_account_requests_path
    expect(response.body).to include("Reason: Rakismet marked as spam")
  end

  it "renders a turbo_stream replacing the request row on approve" do
    put approve_admin_account_request_path(account_requests(:waiting)), as: :turbo_stream
    expect(response.media_type).to eq Mime[:turbo_stream]
    expect(response.body).to include(%(action="replace"))
    expect(response.body).to include(%(target="account_request_#{account_requests(:waiting).id}"))
  end

  it "renders a turbo_stream replacing the request row on deny" do
    put deny_admin_account_request_path(account_requests(:waiting)), as: :turbo_stream
    expect(response.media_type).to eq Mime[:turbo_stream]
    expect(response.body).to include(%(action="replace"))
    expect(response.body).to include(%(target="account_request_#{account_requests(:waiting).id}"))
  end

  it "renders the restyled index with filter pills, action buttons, and card ids" do
    get admin_account_requests_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Waiting')
    expect(response.body).to include('Spammers')
    expect(response.body).to include('Approve')
    expect(response.body).to include('Deny')
    expect(response.body).to include(%(id="account_request_#{account_requests(:waiting).id}"))
  end

  it "renders pagination controls when there is more than one page" do
    25.times do |i|
      AccountRequest.create!(login: "pager#{i}", email: "pager#{i}@example.com",
        entity_type: :musician, details: 'a' * 60, status: :waiting)
    end
    get admin_account_requests_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Page 1 of')
    expect(response.body).to include('Next')
  end

  it "narrows the rendered cards to the requested filter" do
    get admin_account_requests_path
    expect(response.body).to match_css('[id^="account_request_"]', count: AccountRequest.count)

    get admin_account_requests_path(filter_by: 'spammers')
    expect(AccountRequest.spammers.count).to eq(0)
    expect(response.body).not_to match_css('[id^="account_request_"]')
    expect(response.body).to include('No account requests here.')
  end
end
