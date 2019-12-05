# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountRequest, type: :model do

  let(:valid_account_request) do
    AccountRequest.new(
      login: "brandnewband",
      email: "n00bs@n00bs.com",
      entity_type: :band,
      details: "We are a brand new band, nothing yet online, but let us in!"
    )
  end

  context "validation" do
    it "should require an email, login and some details" do
      expect(valid_account_request).to be_valid
    end

    it "should require an entity type" do
      account_request = valid_account_request
      account_request.entity_type = nil
      expect(account_request).not_to be_valid
      expect(account_request.errors[:entity_type]).to_not be_empty
    end

    it "should not allow an already used email" do
      account_request = valid_account_request
      account_request.email = users(:jamie_kiesl).email
      expect(account_request).not_to be_valid
      expect(account_request.errors[:email]).to_not be_empty
    end

    it "should not allow an already used login" do
      account_request = valid_account_request
      account_request.login = users(:jamie_kiesl).login
      expect(account_request).not_to be_valid
      expect(account_request.errors[:login]).to_not be_empty
    end
  end

  context "on approval" do
    it "should be approved" do
      expect(valid_account_request).to be_waiting
      valid_account_request.approve!(users(:sudara))
      expect(valid_account_request).to be_approved
    end

    it "should not be approvable by a non-moderator" do
      expect { valid_account_request.approve!(users(:jamie_kiesl)) }.not_to change { User.count }
    end

    it "should create a user account" do
      expect { valid_account_request.approve!(users(:sudara)) }.to change { User.count }.by(1)
    end

    it "should reset the perishable token and password for the user account" do
      login = valid_account_request.login
      valid_account_request.approve!(users(:sudara))
      user = User.where(login: login)
      expect(user).to exist
      expect(user.take.perishable_token).not_to be_nil
      expect(user.take.crypted_password).not_to be_nil
    end

    it "should populate user's invited_by" do
      login = valid_account_request.login
      valid_account_request.approve!(users(:sudara))
      expect(User.find_by_login(login).invited_by).to eql(users(:sudara))
    end

    it "should populate moderated_by" do
      valid_account_request.approve!(users(:sudara))
      expect(valid_account_request.moderated_by.login).to eql(users(:sudara).login)
    end
  end

  context "on denial" do
    it "should do nothing when denied" do

    end
  end

  context "status" do
    it "should change to accepted when user sets password" do

    end
  end
end
