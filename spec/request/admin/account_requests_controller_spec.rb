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
end
