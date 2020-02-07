require 'rails_helper'

RSpec.describe Admin::AccountRequestsController, type: :request do
  before do
    create_user_session(users(:sudara))
  end

  it "should allow moderators to approve a request" do
    put approve_admin_account_request_path(account_requests(:waiting))
    expect(response).to be_successful
  end

  it "should send an email when a request is approved" do
    expect {
      put approve_admin_account_request_path(account_requests(:waiting))
    }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end
end
