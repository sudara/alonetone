require "rails_helper"

RSpec.describe Playlist, type: :model do
  fixtures :playlists, :tracks, :assets, :users

  it 'should be valid with title, description, user' do
    expect(playlists(:owp)).to be_valid
  end

  it 'should use its permalink as param' do
    expect(playlists(:owp).permalink).to eq(playlists(:owp).to_param)
  end

  it 'should know if it has tracks' do
    expect(playlists(:mix).has_tracks?).to eq(true)
  end

  it 'should know if it is empty (does not have tracks)' do
    expect(playlists(:empty).empty?).to eq(true)
  end

  it "should know playlist is an album" do
    expect(playlists(:owp).is_mix?).to eq(false)
  end

  it 'should be valid' do
    expect(playlists(:owp)).to be_valid
  end

  it "should update a-ok" do
    playlist = playlists(:mix)
    expect(playlist.save).to eq(true)
  end

  it 'should know if it is a mix on update' do
    playlist = playlists(:mix)
    expect(playlist.is_mix?).to eq(true)
  end

  it 'should always belong to a user' do
    expect(playlists(:mix).user).not_to be_nil
  end

  it "should deliver its tracks in order of the position" do
    expect(playlists(:owp).tracks.first.position).to eq(1)
    expect(playlists(:owp).tracks[1].position).to eq(2)
  end

  context "favorites" do
    it 'should create a new playlist for a user who does not have one' do
      expect(users(:sandbags).playlists.favorites).not_to be_present
      users(:sandbags).toggle_favorite(assets(:valid_mp3))
      expect(users(:sandbags).playlists.favorites.first).to be_present
      expect(users(:sandbags).playlists.favorites.first.permalink).not_to be_nil
    end
  end
end
