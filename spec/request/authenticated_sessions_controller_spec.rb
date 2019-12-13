# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticatedSessionsController, type: :request do
  context 'a visitor' do
    it 'sees a login form' do
      get '/authenticated_session/new'
      expect(response).to be_successful
    end

    it 'starts an authenticated session with valid credentials' do
      post(
        '/authenticated_session',
        params: {
          authenticated_session: { login: 'Jamiek', password: 'test' }
        }
      )
      expect(response).to be_redirect
      uri = URI.parse(response.headers['Location'])
      expect(uri.path).to start_with('/Jamiek')
    end

    it 'does not start an authenticated session with invalid credentials' do
      post(
        '/authenticated_session',
        params: {
          authenticated_session: { login: 'Jamiek', password: 'incorrect' }
        }
      )
      expect(response).to be_successful
      expect(response.body).to include('problem logging you in')
    end

    it 'does not start an authenticated session for an inactive user' do
      post(
        '/authenticated_session',
        params: {
          authenticated_session: { login: 'ben', password: 'test' }
        }
      )
      expect(response).to be_successful
      expect(response.body).to include('is not active')
    end

    it 'does not deletes their authenticated session' do
      delete '/authenticated_session'
      expect(response).to be_redirect
      uri = URI.parse(response.headers['Location'])
      get uri.path
      expect(response.body).to include("weren't logged in")
    end
  end

  context 'an authenticated user' do
    before do
      post(
        '/authenticated_session',
        params: {
          authenticated_session: { login: 'Jamiek', password: 'test' }
        }
      )
    end

    it 'deletes their authenticated session' do
      delete '/authenticated_session'
      expect(response).to be_redirect
      uri = URI.parse(response.headers['Location'])
      get uri.path
      expect(response.body).to include('logged you out')
    end
  end
end
