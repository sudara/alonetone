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

  describe "visibility" do
    let(:playlist) do
      Playlist.new(
        is_favorite: false,
        private: false,
        tracks_count: 2
      )
    end

    it "can be public" do
      expect(playlist).to be_public
    end

    it "is not public when contains favorites" do
      playlist.is_favorite = true
      expect(playlist).to_not be_public
    end

    it "is not public when marked as private" do
      playlist.private = true
      expect(playlist).to_not be_public
    end

    it "is not public when has no tracks" do
      playlist.tracks_count = 0
      expect(playlist).to_not be_public
    end
  end

  describe "scopes" do
    it "select playlists which shall be shown on the homepage" do
      playlists = Playlist.for_home.to_a
      # Note: this number may change as fixture are added.
      expect(playlists.size).to eq(2)

      last_time = Time.zone.now
      playlists.each do |playlist|
        expect(playlist.created_at).to be < last_time
        expect(playlist).to be_public

        last_time = playlist.created_at
      end
    end

    it "preload associations to reduce the number of queries" do
      expect(Playlist.with_preloads.count).to eq(Playlist.count)
    end
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

  describe "assigning a new cover image" do
    context "without a cover" do
      let(:playlist) { playlists(:william_shatners_favorites) }

      it "creates the cover" do
        playlist.update!(cover_image: file_fixture_uploaded_file('blue_de_bresse.jpg'))
        expect(playlist.cover_image).to be_attached
      end
    end

    context "with an cover" do
      let(:playlist) { playlists(:will_studd_rockfort) }

      it "replaces the cover" do
        playlist.update!(cover_image: file_fixture_uploaded_file('blue_de_bresse.jpg'))
        expect(playlist.cover_image).to be_attached
      end
    end
  end

  describe "generating URLs to their cover" do
    context "with a cover" do
      let(:playlist) { playlists(:will_studd_rockfort) }

      it "knows the playlist has an cover" do
        expect(playlist.cover_image_present?).to eq(true)
      end

      it "returns a location to a variant" do
        location = playlist.cover_image_location(variant: :large)
        expect(location).to_not be_signed
        expect(location).to be_kind_of(Storage::Location)
        expect(location.attachment).to be_kind_of(ActiveStorage::Variant)
      end
    end

    context "without an cover" do
      let(:playlist) { playlists(:william_shatners_favorites) }

      it "knows the playlist does not have an cover" do
        expect(playlist.cover_image_present?).to eq(false)
      end

      it "does not return a URL to a variant" do
        expect(playlist.cover_image_location(variant: :large)).to be_nil
      end
    end
  end

  describe "soft deletion" do
    it "only soft deletes" do
      expect do
        Playlist.all.map(&:soft_delete)
      end.not_to change { Playlist.unscoped.count }
    end

    it "changes scope" do
      original_count = Playlist.count
      expect do
        Playlist.all.map(&:soft_delete)
      end.to change { Playlist.count }.from(original_count).to(0)
    end
  end
end
