# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationToken, type: :model do
  it 'sets a token after initialization' do
    expect(AuthenticationToken.new.token).to_not be_empty
  end

  it 'uses its token as the request param' do
    authentication_token = AuthenticationToken.new
    expect(authentication_token.to_param).to eq(authentication_token.token)
  end

  it 'does not create without a purpose' do
    expect do
      users(:jamie_kiesl).authentication_tokens.create!
    end.to raise_error(ActiveRecord::NotNullViolation)
  end
end
