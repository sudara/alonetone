require "rails_helper"

RSpec.describe ListensController, type: :request do
  describe "GET /:login/history" do
    it "uses separate page keys for listened tracks and track plays" do
      user = users(:arthur)
      create_user_session(user)

      11.times do |i|
        Listen.create!(
          asset: assets(:valid_mp3),
          listener: user,
          track_owner: users(:sudara),
          created_at: i.minutes.ago
        )
        Listen.create!(
          asset: assets(:valid_arthur_mp3),
          listener: users(:sudara),
          track_owner: user,
          created_at: i.minutes.ago
        )
      end

      get listens_path(user.login)

      expect(response).to be_successful
      expect(response.body).to include("listens_page=2")
      expect(response.body).to include("track_plays_page=2")
    end
  end
end
