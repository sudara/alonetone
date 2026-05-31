require 'rails_helper'

RSpec.describe TracklistHelper, type: :helper do
  # track_descriptor_data leans on UsersHelper#user_avatar_url, which helper
  # specs don't auto-include.
  before { helper.extend(UsersHelper) }

  let(:asset) { assets(:valid_mp3) }

  describe '#track_descriptor_data' do
    it 'emits every key the player descriptor reads' do
      data = helper.track_descriptor_data(asset)

      expect(data).to include(
        track_id: asset.id,
        track_title: asset.name,
        track_artist: asset.user.name,
        track_artist_url: helper.user_home_path(asset.user),
        track_duration: asset.length
      )
      expect(data[:track_url]).to include(asset.permalink, '.mp3')
      expect(data[:track_page_url]).to include(asset.permalink)
      expect(data[:track_image]).to be_present
      expect(data[:track_waveform]).to include(asset.permalink, 'waveform')
    end

    it 'lets callers override url, page_url, image, and title' do
      data = helper.track_descriptor_data(
        asset, url: '/a.mp3', page_url: '/a', image: '/cover.jpg', title: 'Override'
      )

      expect(data).to include(
        track_url: '/a.mp3',
        track_page_url: '/a',
        track_image: '/cover.jpg',
        track_title: 'Override'
      )
    end

    it 'keeps an explicit blank image rather than falling back to the avatar' do
      expect(helper.track_descriptor_data(asset, image: '')[:track_image]).to eq('')
    end
  end
end
