require 'rails_helper'

RSpec.describe 'Admin shell', type: :request do
  describe 'as a moderator' do
    before { create_user_session(users(:sandbags)) }

    it 'renders the dashboard with the nav and range selector' do
      get admin_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('alonetone')
      expect(response.body).to include('Account Requests')
      expect(response.body).to include('Listens')
      expect(response.body).to include('Devops')
      expect(response.body).to include('admin-nav-toggle')
    end

    it 'renders the Listens section stub' do
      get admin_listens_path
      expect(response).to have_http_status(:ok)
    end

    it 'renders the Devops section stub' do
      get admin_devops_path
      expect(response).to have_http_status(:ok)
    end

    it 'persists the range selection in the session' do
      get admin_path, params: { range: '7d' }
      expect(response).to have_http_status(:ok)
      get admin_path
      expect(session[:admin_range]).to eq('7d')
    end

    it 'falls back to the default range when given an unknown value' do
      get admin_path, params: { range: 'bogus' }
      expect(response).to have_http_status(:ok)
      expect(session[:admin_range]).to eq('30d')
    end

    it 'renders the dashboard for the all-time (unbounded) range' do
      get admin_path, params: { range: 'all' }
      expect(response).to have_http_status(:ok)
    end

    it 'leaves not-yet-migrated sections on the legacy layout' do
      get admin_users_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('admin_columns')
      expect(response.body).not_to include('admin-nav-toggle')
    end
  end

  describe 'as a non-moderator' do
    before { create_user_session(users(:arthur)) }

    it 'redirects away from the admin dashboard' do
      get admin_path
      expect(response).to redirect_to(login_path)
    end

    it 'redirects away from the new Listens and Devops sections' do
      get admin_listens_path
      expect(response).to redirect_to(login_path)
      get admin_devops_path
      expect(response).to redirect_to(login_path)
    end
  end
end
