require "rails_helper"

RSpec.describe PasswordResetsController, type: :request do
  context "resetting" do
    it "errors if the email provided doesn't exist" do
      post "/password_resets", params: { email: "blah" }

      expect(response).to redirect_to(login_path)
      expect(flash[:error]).to be_present
    end

    it "disallows logins after resetting" do
      post "/password_resets", params: { email: users(:arthur).email }

      expect(flash[:error]).not_to be_present
      expect(User.where(login: 'arthur').first.perishable_token).not_to be_nil

      post "/user_sessions", params: { user_session: { login: 'arthur', password: 'test' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_credentials]).not_to be_present
    end

    it "sends an email with link to reset pass" do
      post "/password_resets", params: { email: users(:arthur).email }

      expect(last_email.to).to eq([users(:arthur).email])
    end

    it "renders form to reset password given a decent token" do
      post "/password_resets", params: { email: users(:arthur).email }
      get edit_password_reset_path(User.where(login: 'arthur').first.perishable_token)

      expect(response).to be_successful
      expect(flash[:error]).not_to be_present
    end

    it "does not render form to reset password given a bad token" do
      get edit_password_reset_path('oeuouoeu')

      expect(response).to be_redirect
      expect(flash[:error]).to be_present
    end

    it "allows user to manually type in password and login user" do
      post "/password_resets", params: { email: users(:arthur).email }
      put password_reset_path(User.where(login: 'arthur').first.perishable_token),
        params: { user: { password: '12345678', password_confirmation: '12345678' } }

      user = User.where(login: 'arthur').first
      expect(response).to redirect_to('/arthur')
      expect(user.perishable_token).to be_nil
      expect(session[:user_credentials]).to eq(user.persistence_token)
    end

    it "presents edit again if manually typed passwords do not match" do
      post "/password_resets", params: { email: users(:arthur).email }
      put password_reset_path(User.where(login: 'arthur').first.perishable_token),
        params: { user: { password: '123456', password_confirmation: '1234567' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Almost back in, just pick a new password')
      expect(session[:user_credentials]).to eq(nil)
    end
  end

  context "newly invited user" do
    it "redirects to upload_path after choosing a password" do
      put password_reset_path(users(:newly_approved).perishable_token),
        params: { user: { password: '12345678', password_confirmation: '12345678' } }

      expect(response).to redirect_to('/upload')
    end
  end
end
