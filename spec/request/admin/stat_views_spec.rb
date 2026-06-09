require 'rails_helper'

RSpec.describe 'Admin stat views', type: :request do
  before { create_user_session(users(:sudara)) }

  it 'renders Shared IPs' do
    get admin_shared_ips_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Shared IPs')
  end

  it 'groups Shared IPs by current login IP, matching the spam-all action' do
    User.where(login: %w[arthur aaron]).update_all(current_login_ip: '203.0.113.7')
    get admin_shared_ips_path
    expect(response.body).to include('203.0.113.7')
    expect(response.body).to include(users(:arthur).name)
  end

  it 'renders Bandwidth' do
    get admin_bandwidth_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Bandwidth')
  end

  it 'renders Most Played with a range selector and respects the range' do
    get admin_most_played_path, params: { range: '7d' }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Most Played')
    expect(session[:admin_range]).to eq('7d')
  end

  it 'renders All-Time plays' do
    get admin_all_time_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('All-Time')
  end

  it 'requires a moderator' do
    create_user_session(users(:arthur))
    get admin_shared_ips_path
    expect(response).to redirect_to(login_path)
  end
end
