require "rails_helper"

RSpec.describe PasswordResetsController, type: :controller do
  context 'resetting' do
    it "should error if the email provided doesn't exist" do
      post :create, params: { email: "blah" }
      expect(response).to redirect_to(login_path)
      expect(flash[:error]).to be_present
    end

    it "should disallow logins after resetting" do
      activate_authlogic
      post :create, params: { email: users(:arthur).email }
      expect(flash[:error]).not_to be_present
      expect(User.where(login: 'arthur').first.perishable_token).not_to be_nil
      login(:arthur)
      expect(controller.session["user_credentials"]).to eq(nil) # can't login
    end

    it 'should send an email with link to reset pass' do
      post :create, params: { email: users(:arthur).email }
      expect(last_email.to).to eq([users(:arthur).email])
    end

    it 'should render form to reset password given a decent token' do
      post :create, params: { email: users(:arthur).email }
      get :edit, params: { id: User.where(login: 'arthur').first.perishable_token }
      expect(response).to be_successful
      expect(flash[:error]).not_to be_present
    end

    it 'should not render form to reset password given some bullshit token' do
      get :edit, params: { id: 'oeuouoeu' }
      expect(response).to be_redirect
      expect(flash[:error]).to be_present
    end

    it 'should allow user to manually type in password and login user' do
      activate_authlogic
      post :create, params: { email: users(:arthur).email }
      put :update, params: { id: User.where(login: 'arthur').first.perishable_token,
                             user: { password: '12345678', password_confirmation: '12345678' } }
      expect(response).to redirect_to('/arthur')
      expect(User.where(login: 'arthur').first.perishable_token).to be_nil
      expect(controller.session["user_credentials"]).to eq(User.where(login: 'arthur').first.persistence_token) # logged in
    end

    it 'should allow user to manually type in password and present edit again if passes do not match' do
      activate_authlogic
      post :create, params: { email: users(:arthur).email }
      put :update, params: { id: User.where(login: 'arthur').first.perishable_token,
                             user: { password: '123456', password_confirmation: '1234567' } }
      expect(response).to redirect_to(edit_password_reset_path(User.where(login: 'arthur').first.perishable_token))
      expect(controller.session["user_credentials"]).to eq(nil)
    end
  end
end
