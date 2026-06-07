require "rails_helper"

RSpec.describe PlaylistsController, 'routes', type: :routing do
  it 'should generate and recognize friendly routes for playlists (based on permalinks)' do
    expect(get: '/sudara/playlists/owp').to route_to(controller: 'playlists', action: 'show', id: 'owp', user_id: 'sudara')
  end

  it 'should resolve the sort route' do
    expect(get: '/sudara/playlists/sort').to route_to(controller: 'playlists', action: 'sort', user_id: 'sudara')
  end

  it 'should identify playlists by id and route the edit link appropriately' do
    expect(get: '/sudara/playlists/1/edit').to route_to(controller: 'playlists', action: 'edit', id: '1', user_id: 'sudara')
  end

  it 'should route a track within a playlist to playlists#show' do
    expect(get: '/sudara/playlists/owp/song1').to route_to(controller: 'playlists', action: 'show', id: 'owp', user_id: 'sudara', asset_id: 'song1')
  end

  it 'should route a mp3 play within a playlist to playlists#show' do
    expect(get: '/sudara/playlists/owp/song1.mp3').to route_to(controller: 'playlists', action: 'show', id: 'owp', user_id: 'sudara', asset_id: 'song1', format: 'mp3')
  end
end
