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
    subject { users(:arthur).tracks.favorites.create(asset: assets(:valid_mp3)) }
    it "should create a favorite playlist if its the first fav" do
      expect { subject }.to change { Track.count }
    end

    it 'should use an existing favorites playlist' do
    end
  end
end
