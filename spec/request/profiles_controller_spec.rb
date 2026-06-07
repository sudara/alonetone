require "rails_helper"

RSpec.describe ProfilesController, type: :request do
  it "updates a user's profile links" do
    user = users(:arthur)
    create_user_session(user)

    put user_profile_path(user.login), params: {
      profile: {
        bio: 'a little more about me',
        website: 'https://example.com',
        instagram: 'arthur_music'
      }
    }

    expect(response).to redirect_to(edit_user_path(user))
    expect(flash[:ok]).to eq('Saved your links!')
    expect(user.profile.reload.bio).to eq('a little more about me')
    expect(user.profile.website).to eq('example.com')
    expect(user.profile.instagram).to eq('arthur_music')
  end

  it "requires login" do
    put user_profile_path('arthur'), params: { profile: { bio: 'nope' } }

    expect(response).to redirect_to('/login')
  end
end
