require "rails_helper"

RSpec.describe ProfilesController, type: :request do
  before :each do
    create_user_session(users(:sudara))
  end

  describe '#update' do
    describe 'spam user' do
      before :each do
        akismet_stub_response_spam
        put "/#{users(:sudara).login}/profile", params: { profile: { bio: "Studio 45 is known as the best SEO company Ahmed..."} }
      end

      it "should mark user as spam if Akismet check fails" do
        expect(users(:sudara).reload.is_spam).to eq(true)
      end

      it "should raise an error message if Akismet check fails" do
        expect(flash[:error]).to match (/magic fairies/)
      end

      it "should still process user's request even if Akismet check fails" do
        follow_redirect!
        expect(response).to be_successful
      end
    end

    describe 'ham user' do
      before :each do
        akismet_stub_response_ham
      end

      it "should update profile and redirect if Akismet check passes" do
        put "/#{users(:sudara).login}/profile", params: { profile: { bio: "I always loved music."} }
        follow_redirect!
        expect(response).to be_successful
      end
    end
  end
end