require "rails_helper"

RSpec.describe UsersController, type: :request do
  def good_signup_headers
    { 'HTTP_USER_AGENT' => 'Safari', 'REMOTE_ADDR' => '10.1.1.1' }
  end

  context "GET show" do
    it "displays user info route v1" do
      get "/users/#{users(:sudara).login}"
      expect(response).to be_successful
    end

    it "guards moderator Delete/Spam links on a user profile with a turbo-confirm" do
      create_user_session(users(:sudara))
      get "/#{users(:arthur).login}"
      expect(response.body).to include('Delete User')
      expect(response.body).to include('Spam User')
      delete_link = response.body[/<a [^>]*>Delete User<\/a>/]
      spam_link = response.body[/<a [^>]*>Spam User<\/a>/]
      expect(delete_link).to include('data-turbo-confirm=')
      expect(spam_link).to include('data-turbo-confirm=')
    end

    it "does not show moderator Delete/Spam links to regular users" do
      create_user_session(users(:arthur))

      get "/#{users(:sudara).login}"

      expect(response).to be_successful
      expect(response.body).not_to include('Delete User')
      expect(response.body).not_to include('Spam User')
    end

    it "does not show a delete link on a user's own profile" do
      create_user_session(users(:arthur))

      get "/#{users(:arthur).login}"

      expect(response).to be_successful
      expect(response.body).not_to include('Delete User')
    end

    it "displays user info route v2" do
      get "/#{users(:sudara).login}"
      expect(response).to be_successful
    end

    it "displays user info for all users" do
      User.find_each do |user|
        unless user.login.blank?
          get "/#{user.login}"
          expect(response).to be_successful
        end
      end
    end

    # it should display 5 unique titles for assets of latest listens
    it "displays only unique listens on Recently Listened To" do
      # create 5 of the same listen and one extra
      # ensure it definitely shows the other listens
      5.times do |_t|
        Listen.create(asset: assets(:valid_arthur_mp3), listener: users(:sudara), track_owner: users(:arthur))
      end

      get "/#{users(:sudara).login}"

      # from assets(:valid_arthur_mp3)
      expect(response.body).to match(/arthur\/tracks\/song1.mp3/)
      # from listens(:another_valid_asset_to_test_on_latest)
      expect(response.body).to match(/Second hottest asset to test latest/)
      # from assets(:asset_with_relations_for_soft_delete)
      expect(response.body).to match(/Asset to test soft deletion of relations/)
    end
  end

  context "POST create" do
    let(:params) do
      {
        user: {
          login: 'quire',
          email: 'quire@example.com',
          password: 'quire12345',
          password_confirmation: 'quire12345'
        }
      }
    end

    def create_user(overrides = {}, headers: good_signup_headers)
      travel_to 1.day.ago do
        post "/users", params: { user: params[:user].merge(overrides) }, headers: headers
      end
    end

    context "if Akismet check returns not spam" do
      before do
        allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(false)
        akismet_stub_response_ham
      end

      it "should create a user" do
        expect {
          create_user
        }.to change(User, :count).by(1)
      end

      it "should redirect" do
        create_user

        expect(response.status).to eq(302)
        expect(response).to redirect_to(login_url(already_joined: true))
      end

      it "sends the activation email after signup" do
        expect {
          create_user
        }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(last_email.to).to eq(["quire@example.com"])
      end

      it "sets a perishable token for activation" do
        create_user
        expect(User.last.perishable_token).to be_present
      end

      it "does not send the activation email from a bad IP" do
        allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(true)
        headers = good_signup_headers.merge('REMOTE_ADDR' => '60.169.78.123')

        expect {
          create_user(headers: headers)
        }.not_to change { ActionMailer::Base.deliveries.size }
      end

      it "does not send the activation email from a bad user agent" do
        allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(true)
        headers = good_signup_headers.merge('HTTP_USER_AGENT' => 'bot')

        expect {
          create_user(headers: headers)
        }.not_to change { ActionMailer::Base.deliveries.size }
      end

      it "should raise an error if user is invalid" do
        post "/users", params: { user: { login: 'bar', password: 'foo' } }, headers: good_signup_headers

        expect(flash[:error]).to be_present
        expect(response.body).to include('Upload your music')
      end

      [
        [:login, nil],
        [:password, nil],
        [:password_confirmation, nil],
        [:email, nil]
      ].each do |attribute, value|
        it "requires #{attribute} on signup" do
          expect {
            create_user({ attribute => value })
          }.not_to change(User, :count)

          expect(response.body).to include('Upload your music')
          expect(flash[:error]).to be_present
        end
      end
    end

    context "if Akismet check returns spam" do
      before do
        allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(false)
        akismet_stub_response_spam
      end

      it "should return an error message and logout" do
        create_user

        expect(flash[:error]).to match (/magic fairies/)
        expect(response).to redirect_to(logout_path)
      end

      it "should not create a user" do
        expect {
          create_user
        }.not_to change(User, :count)
      end

      it "should set the user to spam before soft deleting" do
        create_user

        expect(User.with_deleted.where(login: params[:user][:login]).first.is_spam).to eq(true)
      end

      it "should mark that user request as soft_deleted" do
        create_user

        expect(User.with_deleted.where(login: params[:user][:login]).first.deleted_at).not_to be_nil
      end

      context "invalid user" do
        before do
          params[:user].delete(:login)
        end

        it "should raise validation error if user's missing login before Akismet check" do
          post "/users", params: { user: params }, headers: good_signup_headers
          expect(flash[:error]).to match(/that didn't quite work/)
        end

        it "should not create user if user is invalid" do
          expect do
            post "/users", params: { user: params }, headers: good_signup_headers
          end.not_to change(User, :count)
        end
      end

      context "spam user" do
        it "should should set user as spam if Akismet check fails" do
          post "/users", params: { user: params }, headers: good_signup_headers
          expect(flash[:error]).to match(/that didn't quite work/)
        end
      end
    end
  end

  context "GET activate" do
    let(:signup_params) do
      {
        user: {
          login: 'quire',
          email: 'quire@example.com',
          password: 'quire12345',
          password_confirmation: 'quire12345'
        }
      }
    end

    before do
      allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(false)
      akismet_stub_response_ham
    end

    def create_pending_user
      post "/users", params: signup_params, headers: good_signup_headers
      User.last
    end

    it "activates with a perishable token" do
      user = create_pending_user

      get "/activate/#{user.perishable_token}", headers: good_signup_headers

      expect(flash[:ok]).to be_present
      expect(response).to redirect_to(new_user_track_path(user.login))
    end

    it "logs in the user after activation" do
      user = create_pending_user

      get "/activate/#{user.perishable_token}", headers: good_signup_headers

      expect(session["user_credentials"]).to eq(user.reload.persistence_token)
    end

    it "sends an activation email" do
      user = create_pending_user

      expect {
        get "/activate/#{user.perishable_token}", headers: good_signup_headers
      }.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(last_email.to).to eq(["quire@example.com"])
    end

    it "does not activate with an invalid perishable token" do
      get "/activate/abunchofbullshit", headers: good_signup_headers

      expect(flash[:error]).to be_present
      expect(response).to redirect_to(new_user_path)
    end

    it "does not activate an account if already logged in" do
      user = create_pending_user
      create_user_session(users(:arthur))

      get "/activate/#{user.perishable_token}", headers: good_signup_headers

      expect(flash[:error]).to be_present
      expect(response).to redirect_to(new_user_track_url(users(:arthur).login))
    end
  end

  context "profile" do
    it "lets the owner edit" do
      create_user_session(users(:arthur))

      get edit_user_path('arthur')

      expect(response).to be_successful
    end

    it "lets an admin edit" do
      create_user_session(users(:sudara))

      get edit_user_path('arthur')

      expect(response).to be_successful
    end

    it "lets the owner update profile fields" do
      user = users(:arthur)
      create_user_session(user)

      patch user_path(user.login), params: {
        user: {
          profile_attributes: { id: user.profile.id, bio: 'a little more about me' }
        }
      }

      expect(response).to redirect_to(edit_user_path(user.reload))
      expect(user.profile.reload.bio).to eq('a little more about me')
    end

    it "lets an admin update profile fields" do
      user = users(:arthur)
      create_user_session(users(:sudara))

      patch user_path(user.login), params: {
        user: {
          profile_attributes: { id: user.profile.id, bio: 'a little more about me' }
        }
      }

      expect(response).to redirect_to(edit_user_path(user.reload))
      expect(user.profile.reload.bio).to eq('a little more about me')
    end

    it "lets a user upload a new photo" do
      user = users(:arthur)
      create_user_session(user)

      patch user_path(user.login), params: {
        user: { avatar_image: fixture_file_upload('jeffdoessudara.jpg', 'image/jpeg') }
      }

      expect(flash[:ok]).to be_present
      expect(response).to redirect_to(edit_user_path(user.reload))
    end

    it "does not allow webp profile photos" do
      user = users(:arthur)
      create_user_session(user)

      patch user_path(user.login), params: {
        user: { avatar_image: fixture_file_upload('alonetone.webp', 'image/webp') }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:error]).to be_present
    end

    it "does not let a user upload a photo for another user" do
      create_user_session(users(:arthur))

      patch user_path('sudara'), params: {
        user: { avatar_image: fixture_file_upload('jeffdoessudara.jpg', 'image/jpeg') }
      }

      expect(response).to redirect_to('/login')
    end

    it "lets a user change their login" do
      create_user_session(users(:arthur))

      patch user_path('arthur'), params: { user: { login: 'arthursaurus' } }

      expect(flash[:error]).not_to be_present
      expect(response).to have_http_status(:see_other)
      expect(User.where(login: 'arthursaurus').count).to eq(1)
    end

    it "does not let a user change login to one that already exists" do
      create_user_session(users(:arthur))

      patch user_path('arthur'), params: { user: { login: 'sudara' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:error]).to be_present
      expect(users(:arthur).reload.login).to eq('arthur')
    end

    it "does not let users edit another profile" do
      create_user_session(users(:arthur))

      get edit_user_path('sudara')

      expect(response).to redirect_to('/login')
    end

    it "does not let users update another profile" do
      create_user_session(users(:arthur))

      patch user_path('sudara'), params: {
        user: {
          profile_attributes: { id: users(:sudara).profile.id, bio: 'a little more about me' }
        }
      }

      expect(response).to redirect_to('/login')
    end

    it "does not let a logged-out user edit" do
      get edit_user_path('arthur')

      expect(response).to redirect_to('/login')
    end
  end

  context "favoriting" do
    let(:asset) { assets(:valid_mp3_2) }

    def toggle_favorite
      put toggle_favorite_path(format: :turbo_stream), params: { asset_id: asset.id }
    end

    it "does not let a guest favorite a track" do
      expect {
        toggle_favorite
      }.not_to change(Track, :count)

      expect(response).to redirect_to('/login')
    end

    it "lets a user favorite a track" do
      create_user_session(users(:arthur))

      expect {
        toggle_favorite
      }.to change(Track, :count).by(1)

      expect(users(:arthur).tracks.favorites.map(&:asset)).to include(asset)
      expect(response).to be_successful
    end

    it "lets a user unfavorite a track" do
      create_user_session(users(:arthur))
      toggle_favorite

      expect {
        toggle_favorite
      }.to change(Track, :count).by(-1)

      expect(users(:arthur).tracks.favorites.map(&:asset)).not_to include(asset)
      expect(response).to be_successful
    end

    it "streams the updated favorites count" do
      create_user_session(users(:arthur))

      toggle_favorite

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include(%(action="update"))
      expect(response.body).to include(%(targets=".favorites_count_#{asset.id}"))
      expect(response.body).to include(asset.reload.favorites_count.to_s)
    end
  end

  context "sudo" do
    it "does not let a normal user sudo" do
      create_user_session(users(:arthur))
      get "/users"

      get sudo_user_path('sudara')

      expect(flash[:ok]).not_to be_present
      expect(response).to redirect_to('/')
      expect(session["user_credentials"]).to eq(users(:arthur).reload.persistence_token)
    end

    it "lets an admin user sudo" do
      create_user_session(users(:sudara))
      get "/users"

      get sudo_user_path('arthur')

      expect(flash[:ok]).to be_present
      expect(session["user_credentials"]).to eq(users(:arthur).reload.persistence_token)
      expect(response).to redirect_to('http://www.example.com/')
    end

    it "lets a sudo'd user return to their admin account" do
      create_user_session(users(:sudara))
      get "/users"
      get sudo_user_path('arthur')
      get "/users"

      get sudo_user_path('arthur')

      expect(flash[:ok]).to be_present
      expect(session["user_credentials"]).to eq(users(:sudara).reload.persistence_token)
      expect(response).to redirect_to('http://www.example.com/')
    end

    it "does not update the sudo target's IP or last_request_at" do
      user = users(:arthur)
      current_login_ip = user.current_login_ip
      last_request_at = user.last_request_at
      create_user_session(users(:sudara))

      get sudo_user_path(user.login), headers: { 'REMOTE_ADDR' => '10.1.1.1' }

      expect(session["user_credentials"]).to eq(user.reload.persistence_token)
      expect(user.reload.current_login_ip).to eq(current_login_ip)
      expect(user.last_request_at.utc).to eq(last_request_at.utc)
    end
  end

  context "#destroy" do
    it "lets an admin soft-delete another user and associated visible records" do
      user = users(:arthur)
      create_user_session(users(:sudara))

      expect(user.assets.count).to be > 0
      expect(user.tracks.count).to be > 0
      expect(user.listens.count).to be > 0
      expect(user.playlists.count).to be > 0

      expect {
        delete user_path(user.login), params: { login: user.login }
      }.to change(User, :count).by(-1)

      expect(response).to redirect_to(root_url)
      expect(user.reload.deleted_at).to be_present
      expect(user.assets.count).to eq(0)
      expect(user.tracks.count).to eq(0)
      expect(user.listens.count).to eq(0)
      expect(user.playlists.count).to eq(0)
      expect(user.comments_received.count).to eq(0)
    end
  end

  context "PUT toggle_setting" do
    let(:user) { users(:sudara) }

    before do
      create_user_session(user)
    end

    it "toggles a recognized setting and returns 200" do
      expect {
        put toggle_setting_user_path(user), params: { setting: 'block_guest_comments' }
      }.to change { user.settings.reload.block_guest_comments? }
      expect(response).to have_http_status(:ok)
    end

    it "returns 400 for an unknown setting" do
      put toggle_setting_user_path(user), params: { setting: 'not_a_real_setting' }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
