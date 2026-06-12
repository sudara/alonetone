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

  it 'lists at most 6 accounts for a shared IP' do
    sharers = User.order(:id).limit(7)
    sharers.update_all(current_login_ip: '203.0.113.50')
    get admin_shared_ips_path
    listed = sharers.count { |user| response.body.include?("possibly_deleted_user/#{user.login}") }
    expect(listed).to eq(6)
    expect(response.body).to include('7 accounts')
  end

  it 'renders Bandwidth' do
    get admin_bandwidth_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Bandwidth')
  end

  it 'computes ranged bandwidth from listens for a bounded range' do
    get admin_bandwidth_path, params: { range: '7d' }
    expect(response).to have_http_status(:ok)
    expect(session[:admin_range]).to eq('7d')
    expect(response.body).to include(users(:sudara).name)
  end

  it 'prices ranged bandwidth as in-range listens times audio file size' do
    asset = assets(:valid_mp3)
    200.times { asset.listens.create!(track_owner: asset.user) }
    in_range = Listen.where(asset_id: asset.id, created_at: 7.days.ago..Time.current).count
    gb = in_range * asset.audio_file.byte_size.to_f / 1.gigabyte
    expect(gb).to be > 0.05
    get admin_bandwidth_path, params: { range: '7d' }
    expect(response.body).to include("#{gb.round(1)} GB")
  end

  it 'uses the cached all-time bandwidth for the all range' do
    users(:sudara).update_columns(bandwidth_used: 42)
    get admin_bandwidth_path, params: { range: 'all' }
    expect(response.body).to include('42 GB')
  end

  it 'includes soft-deleted users in the bandwidth list' do
    users(:arthur).update_columns(bandwidth_used: 37, deleted_at: 10.days.ago)
    get admin_bandwidth_path, params: { range: 'all' }
    expect(response.body).to include(users(:arthur).name)
    expect(response.body).to include('37 GB')
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

  it 'survives assets whose owner row no longer exists' do
    asset = assets(:valid_mp3)
    asset.update_columns(user_id: User.with_deleted.maximum(:id) + 1, listens_count: 9_999_999)
    asset.listens.update_all(created_at: 1.day.ago)
    get admin_all_time_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(asset.title)
    get admin_most_played_path, params: { range: '7d' }
    expect(response).to have_http_status(:ok)
  end

  it 'requires a moderator' do
    create_user_session(users(:arthur))
    get admin_shared_ips_path
    expect(response).to redirect_to(login_path)
  end
end
