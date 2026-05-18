require "rails_helper"

RSpec.describe 'favoriting tracks', type: :feature, js: true do
  def wait_until(timeout: 2, &block)
    deadline = Time.now + timeout
    loop do
      result = block.call
      return result if result
      raise "timeout waiting for condition" if Time.now > deadline

      sleep 0.05
    end
  end

  it 'lets a logged-in user fave and then unfave from the cached home-page list' do
    logged_in(:arthur) do
      visit '/'
      track = find('.asset', match: :first)
      track.find('.play_link').click

      expect(track).to have_selector('.add_to_favorites')

      asset_id = track.find('.add_to_favorites')['data-favorite-id-value'].to_i
      expect(users(:arthur).favorite_asset_ids).not_to include(asset_id)
      expect(JSON.parse(page.find('body')['data-user-favorites-ids-value'])).not_to include(asset_id)

      track.find('.add_to_favorites').click
      wait_until { users(:arthur).reload.favorite_asset_ids.include?(asset_id) }
      expect(JSON.parse(page.find('body')['data-user-favorites-ids-value'])).to include(asset_id)

      track.find('.add_to_favorites').click
      wait_until { !users(:arthur).reload.favorite_asset_ids.include?(asset_id) }
      expect(JSON.parse(page.find('body')['data-user-favorites-ids-value'])).not_to include(asset_id)
    end
  end

  it 'lets a logged-in user unfave a track that was already favorited at page load' do
    asset_id = assets(:valid_mp3).id
    expect(users(:arthur).favorite_asset_ids).to include(asset_id)

    logged_in(:arthur) do
      visit user_track_path(assets(:valid_mp3).user.login, assets(:valid_mp3).permalink)

      # detail page renders shared/_asset.html.erb which is NOT inside the cache
      expect(page).to have_selector('.add_to_favorites')
      page.find('.add_to_favorites').click

      wait_until { !users(:arthur).reload.favorite_asset_ids.include?(asset_id) }
    end
  end
end
