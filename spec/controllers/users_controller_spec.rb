require "rails_helper"

RSpec.describe UsersController, type: :controller do

  fixtures :users, :assets

  context 'creating' do
    it "should successfully post to users/create" do
      create_user
      expect(response).to redirect_to("/login?already_joined=true")
    end

    it "should send user activation email after signup" do
      create_user
      expect(last_email.to).to eq(["quire@example.com"])
    end

    it "should have actually created the user" do
      expect { create_user }.to change(User, :count).by(1)
    end

    it 'should reset the perishable token' do
      create_user
      expect(assigns(:user).perishable_token).to_not be_nil
    end

    it "should require login on signup" do
      create_user :login => nil
      expect(response).to_not be_redirect
      expect(assigns(:user).errors[:login].size).to be >= 1
    end

    it "should require password on signup" do
      create_user :password => nil
      expect(response).to_not be_redirect
      expect(assigns(:user).errors[:password].size).to be >= 1
    end

    it "should require password confirmation on signup" do
      create_user :password_confirmation => nil
      expect(response).to be_success
      expect(assigns(:user).errors[:password_confirmation].size).to be >= 1
    end

    it "should require email on signup" do
      create_user :email => nil
      expect(response).to be_success
      expect(assigns(:user).errors[:email].size).to be >= 1
    end
  end

  context 'activation' do

    it "should activate with a for reals perishable token" do
      activate_authlogic && create_user
      get :activate, :perishable_token => User.last.perishable_token
      expect(flash[:ok]).to be_present
      expect(response).to redirect_to(new_user_track_path(User.last.login))
    end

    it 'should log in user on activation' do
      activate_authlogic && create_user
      #expect(UserSession).to receive(:create)
      get :activate, :perishable_token => User.last.perishable_token
      expect(controller.session["user_credentials"]).to eq(User.last.persistence_token)
    end

    it 'should send out email on activation' do
      activate_authlogic && create_user
      get :activate, :perishable_token => User.last.perishable_token
      expect(last_email.to).to eq(["quire@example.com"])
    end

    it "should not activate with bullshit perishable token" do
      activate_authlogic
      get :activate, :perishable_token => "abunchofbullshit"
      expect(flash[:error]).to be_present
      expect(response).to redirect_to(new_user_path)
    end

    it 'should NOT activate an account if you are already logged in' do
      login(:arthur)
      create_user
      get :activate, :perishable_token => User.last.perishable_token
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("http://test.host/arthur/tracks/new")
    end

    it 'should NOT activate if you are on a shitty ass IP' do
      activate_authlogic && create_user
      @request.env['REMOTE_ADDR'] = '60.169.78.123' # example bad ip
      get :activate, :perishable_token => User.last.perishable_token
      expect(flash[:error]).to be_present
    end

  end
  context "profile" do

    fixtures :users, :assets
    [:sudara, :arthur].each do |user|
      it "should let a user or admin edit" do
        login(user)
        allow(controller).to receive(:current_user).and_return(users(user))
        post :edit, :id => 'arthur'
        expect(response).to be_success
      end

      it "should let a user or admin update" do
        login(user)
        allow(controller).to receive(:current_user).and_return(users(user))
        put :update, :id => 'arthur', :user => {:bio => 'a little more about me'}
        expect(response).to redirect_to(edit_user_path(users(:arthur)))
      end
    end

    it "should let a user upload a new photo" do
      login(:arthur)
      post :attach_pic, :id => users(:arthur).login, :pic => {:pic => fixture_file_upload('images/jeffdoessudara.jpg','image/jpeg')}
      expect(flash[:ok]).to be_present
      expect(response).to redirect_to(edit_user_path(users(:arthur)))
    end

    it "should not let a user upload a new photo for another user" do
      login(:arthur)
      post :attach_pic, :id => users(:sudara).login, :pic => {:pic => fixture_file_upload('images/jeffdoessudara.jpg','image/jpeg')}
      expect(response).to redirect_to('/login')
    end

    it "should let a user change their login" do
      login(:arthur)
      put :update, :id => 'arthur', :user => {:login => 'arthursaurus'}
      expect(flash[:error]).not_to be_present
      expect(response).to be_redirect
      expect(User.where(:login => 'arthursaurus').count).to eq(1)
    end

    it 'should not let a user change login to login that exists' do
      login(:arthur)
      put :update, :id => 'arthur', :user => {:login => 'sudara'}
      expect(flash[:error]).to be_present
      expect(User.where(:login => 'sudara').count).to eq(1)
    end

    it "should not let any old user edit" do
      login(:arthur)
      allow(controller).to receive(:current_user).and_return(users(:arthur))
      post :edit, :id => 'sudara'
      expect(response).not_to be_success
    end

    it "should not let any old user update" do
      login(:arthur)
      allow(controller).to receive(:current_user).and_return(users(:arthur))
      put :update,  :id => 'sudara', :user => { :bio => 'a little more about me' }
      expect(response).not_to be_success
    end

    it "should not let a logged out user edit" do
      logout
      post :edit, :user_id => 'arthur'
      expect(response).not_to be_success
    end

    it 'should deliver an rss feed for any user, to anyone' do
      get :show, :id => 'sudara', :format => 'rss'
      expect(response).to be_success
    end
  end

  context "favoriting" do
    subject { xhr :get, :toggle_favorite, :asset_id => 100 }

    it 'should not let a guest favorite a track' do
      expect { subject }.to change{ Track.count }.by(0)
      expect(response).not_to be_success
    end

    it 'should let a user favorite a track' do
      login(:arthur)
      expect { subject }.to change{ Track.count }.by(1)
      expect(users(:arthur).tracks.favorites.collect(&:asset)).to include(Asset.find(100))
      expect(response).to be_success
    end

    it 'should let a user unfavorite a track' do
      login(:arthur)
      expect { subject }.to change{ Track.count }.by(1)
      get :toggle_favorite, :asset_id => 100  # toggle again
      expect(users(:arthur).tracks.favorites.collect(&:asset)).not_to include(Asset.find(100))
      expect(response).to be_success
    end
  end

  context "sudo" do
    it "should not let a normal user sudo" do
      controller.session[:return_to] = '/users'
      login(:arthur)
      get :sudo, :id => 'sudara'
      expect(flash[:ok]).not_to be_present
      expect(response).to redirect_to '/'
    end

    it "should let an admin user sudo" do
      login(:sudara)
      controller.session[:return_to] = '/users'
      get :sudo, :id => 'arthur'
      expect(flash[:ok]).to be_present
      expect(controller.session["user_credentials"]).to eq(users(:arthur).persistence_token)
      expect(response).to redirect_to '/users'
    end

    it "should let an sudo'd user return to their admin account" do
      login(:arthur)
      controller.session[:return_to] = '/users'
      controller.session[:sudo] = 1
      get :sudo, :id => 'arthur'
      expect(flash[:ok]).to be_present
      expect(controller.session["user_credentials"]).to eq(users(:sudara).persistence_token)
      expect(response).to redirect_to '/users'
    end

    it "should not update IP or last_request_at" do
      request.env['REMOTE_ADDR'] = '10.1.1.1'
      login(:sudara)
      get :sudo, :id => 'arthur'
      expect(controller.session["user_credentials"]).to eq(users(:arthur).persistence_token)
      expect(users(:arthur).current_login_ip).not_to eq('10.1.1.1')
      expect(users(:arthur).last_request_at.to_s).to eq(1.day.ago.to_s) # shouldn't have changed from yml
    end
  end

  context "last request at" do
    it "should touch last_request_at when logging in" do
      # Authlogic does this by default, which fucks things up
      expect { login(:arthur) }.to change{ users(:arthur).last_request_at}
    end

    # it "should touch last_request_at when doing anything" do
    #   Timecop.travel(12.minute.ago)
    #    login(:arthur)
    #   Timecop.travel(1.minute.ago)
    #   expect { get :index }.to change{ User.find_by_login("arthur").last_request_at}
    #
    # end
    #
    # it "should not touch updated_at when logging in" do
    #   # Authlogic does this by default, which fucks things up
    #   expect { login(:arthur) }.to_not change{ User.find_by_login("arthur").updated_at }
    # end
  end

end

def create_user(options = {})
  Timecop.travel(1.day.ago)
  post :create, :user => { :login => 'quire', :email => 'quire@example.com', :password => 'quire12345', :password_confirmation => 'quire12345'}.merge(options)
  Timecop.return
end
