require "rails_helper"

RSpec.describe Track, type: :model do
  it "should be valid with a asset_id and a playlist_id" do
    expect(tracks(:owp1)).to be_valid
  end

  it "is not valid without a playlist_id" do
    expect(tracks(:no_playlist_id)).not_to be_valid
  end

  it "should be valid without a user_id" do
    expect(tracks(:owp2)).to be_valid
  end

  context "as a fav" do
    let(:user) { users(:will_studd) }

    it "should create a favorite playlist if its the first fav" do
      expect(user.playlists.favorites.count).to eq(0)
      expect do
        user.tracks.favorites.create(asset: assets(:henri_willig_finest_cheese))
      end.to change(Track, :count).by(+1)
      expect(user.playlists.favorites.count).to eq(1)
    end

    it 'should use an existing favorites playlist' do
      expect(user.playlists.favorites.count).to eq(0)
      expect do
        user.tracks.favorites.create(asset: assets(:henri_willig_finest_cheese))
        user.tracks.favorites.create(asset: assets(:henri_willig_the_goat))
      end.to change(Track, :count).by(+2)
      expect(user.playlists.favorites.count).to eq(1)
    end
  end
end
