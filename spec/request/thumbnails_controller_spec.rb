# frozen_string_literal: true

require "rails_helper"

RSpec.describe ThumbnailsController, type: :request do
  context "a visitor" do
    it "sees a thumbnail of a cover image" do
      playlist = playlists(:will_studd_rockfort)
      get(
        "/thumbnails/#{playlist.cover_image.key}",
        params: {
          crop: '1:1',
          quality: 42,
          width: 10
        }
      )
      expect(response).to be_successful
      expect(response.headers['Content-Type']).to eq('image/jpeg')
      expect(response.headers['ETag']).to_not be_nil
      expect(response.headers['Expires']).to include(Time.zone.now.year.to_s)
      expect(response.headers['Cache-Control']).to include('public')
    end

    it "does not see a thumbnail for an unknown image" do
      get(
        "/thumbnails/non-existent",
        params: {
          crop: '1:1',
          quality: 42,
          width: 10
        }
      )
      expect(response).to have_http_status(:not_found)
    end
  end
end
