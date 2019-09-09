require "rails_helper"

RSpec.describe ProfilesController, type: :controller do
  context "spam update" do
    before :each do
      akismet_stub_response_spam
    end

    %i[sudara].each do |user|
      before :each do
        login(user)
      end

      it "should flash a message and logout" do
        put :update, params: { user_id: 'sudara', profile: { bio: 'very spammy bio' } }
        expect(flash[:error]).to match (/magic fairies/)
        expect(response).to redirect_to(logout_path)
      end

      it "should mark user as spam if Akismet returns spam" do
        put :update, params: { user_id: 'sudara', profile: { bio: 'very spammy bio' } }
        expect(User.with_deleted.where(login: 'sudara').first.is_spam?).to eq(true)
      end

      it "should soft delete the user" do
        put :update, params: { user_id: 'sudara', profile: { bio: 'very spammy bio' } }
        expect(User.with_deleted.where(login: 'sudara').first.deleted?).to eq(true)
      end

      it "should soft delete user" do
        expect do
          put :update, params: { user_id: 'sudara', profile: { bio: 'very spammy bio' } }
        end.to change(User, :count).by(-1)
      end

      it "should soft delete users assets" do
        asset_count = users(:sudara).assets.count
        expect do
          put :update, params: { user_id: 'sudara', profile: { bio: 'very spammy bio' } }
        end.to change(Asset, :count).by(-asset_count)
      end

      it "should soft delete users listens" do
        # inclides records where user is both owner and just listener
        expect do
          put :update, params: { user_id: 'sudara', profile: { bio: 'very spammy bio' } }
        end.to change(Listen, :count).by(-3)
      end

      it "should soft delete users playlists" do
        playlist_count = users(:sudara).playlists.count
        expect do
          put :update, params: { user_id: 'sudara', profile: { bio: 'very spammy bio' } }
        end.to change(Playlist, :count).by(-playlist_count)
      end

      it "should soft delete users tracks" do
        expect do
          put :update, params: { user_id: 'sudara', profile: { bio: 'very spammy bio' } }
        end.to change(Track, :count).by(-8)
      end

      it "should soft delete users comments" do
        expect do
          put :update, params: { user_id: 'sudara', profile: { bio: 'very spammy bio' } }
        end.to change(Comment, :count).by(-10)
      end

      it "should soft delete users topics" do
        topics_count = users(:sudara).topics.count
        expect do
          put :update, params: { user_id: 'sudara', profile: { bio: 'very spammy bio' } }
        end.to change(Topic, :count).by(-topics_count)
      end
    end
  end
end