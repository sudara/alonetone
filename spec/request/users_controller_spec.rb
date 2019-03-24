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
    context "if Akismet check returns ham" do
      before do
        allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(false)
        akismet_stub_response_ham
      end

      it "should create a user" do
        expect {
          post "/users", params: params
        }.to change(User, :count).by(1)
      end

      it "should redirect" do
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

    context "if Akismet check returns spam" do
      before do
        allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(false)
        akismet_stub_response_spam
      end

      it "should return an error message and logout" do
        post "/users", params: params

        expect(flash[:error]).to match (/magic fairies/)
        expect(response).to redirect_to(logout_path)
      end

      it "should not create a user" do
        expect {
          post "/users", params: params
        }.not_to change(User, :count)
      end
    end
  end
end
