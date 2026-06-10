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

    it 'bans an ip without purging its listens' do
      expect do
        post admin_ban_ip_path(ip: '203.0.113.20')
      end.not_to have_enqueued_job(PurgeListensByIpJob)
      expect(BannedIp.banned?('203.0.113.20')).to be(true)
    end

    it 'purges listens for a banned ip on request' do
      banned = BannedIp.create!(ip: '203.0.113.22')
      expect do
        post admin_purge_banned_ip_path(banned)
      end.to have_enqueued_job(PurgeListensByIpJob).with('203.0.113.22')
    end

    it '404s when purging an unknown banned ip id' do
      post admin_purge_banned_ip_path(id: 999_999)
      expect(response).to have_http_status(:not_found)
    end

    it 'bans a CIDR range' do
      post admin_ban_ip_path(ip: '47.82.0.0/16')
      expect(BannedIp.banned?('47.82.10.35')).to be(true)
    end

    it 'refuses to purge an ipv6 range' do
      banned = BannedIp.create!(ip: '2001:db8::/32')
      expect do
        post admin_purge_banned_ip_path(banned)
      end.not_to have_enqueued_job(PurgeListensByIpJob)
    end

    it 'marks listening ips covered by a range ban as banned' do
      BannedIp.create!(ip: '198.51.0.0/16')
      asset = assets(:valid_mp3)
      asset.listens.create!(track_owner: asset.user, ip: '198.51.100.77')
      get admin_listens_path, params: { range: '7d' }
      expect(response.body).to include('198.51.100.77')
      expect(response.body).to include('>banned<')
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

    it 'cannot unban an ip (unban is admin-only)' do
      banned = BannedIp.create!(ip: '203.0.113.31')
      delete admin_banned_ip_path(banned)
      expect(BannedIp.exists?(banned.id)).to be(true)
    end

    it 'cannot purge listens (purge is admin-only)' do
      banned = BannedIp.create!(ip: '203.0.113.32')
      expect do
        post admin_purge_banned_ip_path(banned)
      end.not_to have_enqueued_job(PurgeListensByIpJob)
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

    it 'denies the mp3 redirect to a banned ip' do
      BannedIp.create!(ip: '203.0.113.41')
      BannedIp.clear_cache
      get user_track_path('sudara', 'song1', format: :mp3),
        headers: { 'REMOTE_ADDR' => '203.0.113.41', 'HTTP_ACCEPT' => 'audio/mpeg',
                   'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en) AppleWebKit/XX (KHTML, like Gecko) Safari/YY' }
      expect(response).to have_http_status(:forbidden)
    end

    it 'denies the mp3 redirect to an ip covered by a range ban' do
      BannedIp.create!(ip: '203.0.0.0/16')
      BannedIp.clear_cache
      get user_track_path('sudara', 'song1', format: :mp3),
        headers: { 'REMOTE_ADDR' => '203.0.113.43', 'HTTP_ACCEPT' => 'audio/mpeg',
                   'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en) AppleWebKit/XX (KHTML, like Gecko) Safari/YY' }
      expect(response).to have_http_status(:forbidden)
    end

    it 'still redirects an unbanned ip to the mp3' do
      get user_track_path('sudara', 'song1', format: :mp3),
        headers: { 'REMOTE_ADDR' => '203.0.113.42', 'HTTP_ACCEPT' => 'audio/mpeg',
                   'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en) AppleWebKit/XX (KHTML, like Gecko) Safari/YY' }
      expect(response).to have_http_status(:found)
    end
  end
end
