require "rails_helper"

RSpec.describe UsersController, type: :request do
  fixtures :users, :profiles

  before :each do
    create_user_session(users(:sudara))
  end

  context "GET show" do
    it "displays user info route v1" do
      get "/users/#{users(:sudara).login}"
      expect(response).to be_success
    end

    it "displays user info route v2" do
      get "/#{users(:sudara).login}"
      expect(response).to be_success
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
      post "/users", params: params

      expect(response.status).to eq(302)
      expect(response).to redirect_to(login_url(already_joined: true))
    end

    it "should raise an error if user is invalid" do
      post "/users", params: { user: { login: 'bar', password: 'foo' } }

      expect(flash[:error]).to be_present
      expect(response).to render_template("users/new")
    end
  end
end
