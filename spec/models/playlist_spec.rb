require "rails_helper"

RSpec.describe Playlist, type: :model do
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

  describe 'cover quality' do
    it 'defaults to modern' do
      playlist = Playlist.new
      expect(playlist.cover_quality).to eq('modern')
      expect(playlist.modern_cover_quality?).to eq(true)
    end

    it 'can be ancient' do
      playlist = playlists(:henri_willig_polderkaas)
      playlist.update(cover_quality: :ancient)
      expect(playlist.cover_quality).to eq('ancient')
    end

    it 'can be legacy' do
      playlist = playlists(:henri_willig_polderkaas)
      playlist.update(cover_quality: :legacy)
      expect(playlist.cover_quality).to eq('legacy')
    end
  end

  describe "generating URLs to their cover" do
    context "with a cover" do
      let(:playlist) { playlists(:will_studd_rockfort) }

      it "knows the playlist has an cover" do
        expect(playlist.cover_image_present?).to eq(true)
      end

      it "returns a URL to a variant" do
        url = playlist.cover_url(variant: :large)
        expect(url).to start_with('/system/pics')
        expect(url).to end_with('.jpg')
      end
    end

    context "with an cover that has missing information" do
      let(:playlist) { playlists(:henri_willig_polderkaas) }

      it "knows the playlist does not have an cover" do
        expect(playlist.cover_image_present?).to eq(false)
      end

      it "does not return a URL to a variant" do
        expect(playlist.cover_url(variant: :large)).to be_nil
      end
    end

    context "without an cover" do
      let(:playlist) { playlists(:william_shatners_favorites) }

      it "knows the playlist does not have an cover" do
        expect(playlist.cover_image_present?).to eq(false)
      end

      it "does not return a URL to a variant" do
        expect(playlist.cover_url(variant: :large)).to be_nil
      end
    end
  end
end
