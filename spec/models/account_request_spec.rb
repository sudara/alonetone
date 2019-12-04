# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountRequest, type: :model do

  context "validation" do
    let(:valid_account_request) do
      AccountRequest.new(
        login: "brandnewband",
        email: "n00bs@n00bs.com",
        entity_type: :band,
        details: "We are a brand new band, nothing yet online, but let us in!"
      )
    end

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
end