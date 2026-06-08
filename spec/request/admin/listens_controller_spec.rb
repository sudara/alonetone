require 'rails_helper'

RSpec.describe Admin::ListensController, type: :request do
  describe 'as an admin' do
    before { create_user_session(users(:sudara)) }

    it 'renders the Listening IPs view' do
      get admin_listens_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Listening IPs')
    end

    it 'renders the Banned IPs view' do
      get admin_banned_ips_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Banned IPs')
    end

    it 'bans an ip and enqueues a purge of its listens' do
      expect do
        post admin_ban_ip_path(ip: '203.0.113.20')
      end.to have_enqueued_job(PurgeListensByIpJob).with('203.0.113.20')
      expect(BannedIp.banned?('203.0.113.20')).to be(true)
    end

    it 'unbans an ip' do
      banned = BannedIp.create!(ip: '203.0.113.21')
      delete admin_banned_ip_path(banned)
      expect(BannedIp.exists?(banned.id)).to be(false)
    end

    it 'rejects an invalid ip without enqueuing a purge' do
      expect do
        post admin_ban_ip_path(ip: 'garbage')
      end.not_to have_enqueued_job(PurgeListensByIpJob)
      expect(BannedIp.banned?('garbage')).to be(false)
    end
  end

  describe 'as a moderator (not admin)' do
    before { create_user_session(users(:sandbags)) }

    it 'cannot ban an ip (ban + purge is admin-only)' do
      post admin_ban_ip_path(ip: '203.0.113.30')
      expect(BannedIp.banned?('203.0.113.30')).to be(false)
    end
  end

  describe 'listen enforcement' do
    it 'does not record a listen from a banned ip' do
      BannedIp.create!(ip: '203.0.113.40')
      BannedIp.clear_cache
      asset = assets(:valid_mp3)
      expect do
        post register_listen_path(id: asset.id),
          headers: { 'REMOTE_ADDR' => '203.0.113.40', 'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh)' }
      end.not_to change(Listen, :count)
    end
  end
end
