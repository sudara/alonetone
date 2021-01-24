# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserCreation, type: :controller do
  controller(ActionController::Base) do
    include PreventAbuse
    include UserCreation

    def create
      respond_with_user(
        User.new(
          email: 'jeremy@example.com',
          login: 'Jeremy',
          password: 'secret123-',
          password_confirmation: 'secret123-'
        )
      )
    end
  end

  before do
    controller.request.env['HTTP_USER_AGENT'] = 'webkit'
  end

  context 'with user' do
    before do
      akismet_stub_response_ham
      controller.request.remote_addr = '62.251.41.177'
    end

    it 'saves the record and redirects to the login page' do
      expect { post :create }.to change(User, :count).by(+1)
      expect(response).to redirect_to(login_url(already_joined: true))
    end
  end

  context 'with user attributes marked as spam' do
    before do
      akismet_stub_response_spam
      controller.request.remote_addr = '62.251.41.177'
    end

    it 'does not save the record and redirects to the login page' do
      expect { post :create }.to_not change(User, :count)
      expect(response).to redirect_to(login_url(already_joined: true))
    end
  end

  context 'with user from a request identified as spammer' do
    before do
      akismet_stub_response_ham
      controller.request.remote_addr = '121.14.1.1'
    end

    it 'does not save the record and redirects to the login page' do
      expect { post :create }.to_not change(User, :count)
      expect(response).to redirect_to(login_url(already_joined: true))
    end
  end
end
