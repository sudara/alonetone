require "rails_helper"

RSpec.describe UsersController, type: :request do
  before :each do
    create_user_session(users(:sudara))
  end

  context "GET show" do
    it "displays user info route v1" do
      get "/users/#{users(:sudara).login}"
      expect(response).to be_successful
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

    it "should create a user and redirect" do
      akismet_stub_response_ham
      post "/users", params: params

      expect(response.status).to eq(302)
      expect(response).to redirect_to(login_url(already_joined: true))
    end

    it "should raise an error if user is invalid" do
      akismet_stub_response_ham
      post "/users", params: { user: { login: 'bar', password: 'foo' } }

      expect(flash[:error]).to be_present
      expect(response).to render_template("users/new")
    end

    it "should raise an error if user fails Akismet check" do
      akismet_stub_response_spam
      post "/users", params: params

      expect(flash[:error]).to match (/magic fairies/)
      expect(response).to render_template("users/new")
    end

    it "should mark user as spam if Akismet check fails" do
      akismet_stub_response_spam
      post "/users", params: params

      expect(assigns(:user).is_spam?).to eq(true)
    end
  end
end
