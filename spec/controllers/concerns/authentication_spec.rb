# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Authentication, type: :controller do
  controller(ActionController::Base) do
    include Authentication
  end

  it 'does not find the current user session' do
    expect(controller.current_user_session).to be_nil
  end

  it 'does not find the current user' do
    expect(controller.current_user).to be_nil
  end

  it 'is not logged in' do
    expect(controller).to_not be_logged_in
  end

  context 'authenticated' do
    let(:user) { users(:henri_willig) }

    before do
      UserSession.create!(login: user.login, password: 'test', remember_me: true)
    end

    it 'finds the current user session' do
      expect(controller.current_user_session).to_not be_nil
    end

    it 'finds the current user' do
      expect(controller.current_user).to_not be_nil
    end

    it 'is logged in' do
      expect(controller).to be_logged_in
    end
  end
end
