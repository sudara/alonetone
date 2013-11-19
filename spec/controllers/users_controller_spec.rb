require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  
  fixtures :users
  
  context 'creating' do   
    it "should successfully post to users/create" do
      create_user
      response.should redirect_to("/login?already_joined=true")
    end
    
    it "should send user activation email after signup" do
      create_user
      ActionMailer::Base.deliveries.last.to.should == ["quire@example.com"]
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
      expect(assigns(:user)).to have_at_least(1).errors_on(:login)
    end

    it "should require password on signup" do
      create_user :password => nil 
      expect(response).to_not be_redirect
      expect(assigns(:user)).to have_at_least(1).errors_on(:password)
    end

    it "should require password confirmation on signup" do
      create_user :password_confirmation => nil 
      response.should be_success
      expect(assigns(:user)).to have_at_least(1).errors_on(:password_confirmation)
    end

    it "should require email on signup" do
      create_user :email => nil 
      response.should be_success
      expect(assigns(:user)).to have_at_least(1).errors_on(:email)
    end
  end
  
  context 'activation' do 
    
    it "should activate with a for reals perishable token" do 
      activate_authlogic && create_user
      controller.stub(:logged_in).and_return(false)
      get :activate, :perishable_token => User.last.perishable_token
      expect(flash[:error]).to_not be_present
      response.should be_redirect
    end
    
    it 'should log in user on activation' do 
      activate_authlogic && create_user      
      expect(UserSession).to receive(:create)
      get :activate, :perishable_token => User.last.perishable_token
    end
    
    it 'should send out email on activation' do 
      activate_authlogic && create_user
      get :activate, :perishable_token => User.last.perishable_token
      ActionMailer::Base.deliveries.last.to.should == ["quire@example.com"]
    end
    
    it "should not activate with bullshit perishable token" do
      activate_authlogic
      get :activate, :perishable_token => "abunchofbullshit"
      expect(flash[:error]).to be_present
      response.should redirect_to(new_user_path)
    end
  
    it 'should NOT activate an account if you are already logged in' do
      login(:arthur)
      create_user
      get :activate, :perishable_token => User.last.perishable_token
      expect(flash[:error]).to be_present
      response.should redirect_to("http://test.host/arthur/tracks/new")
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
        controller.stub(:current_user).and_return(users(user))
        post :edit, :id => 'arthur'
        response.should be_success
      end
  
      it "should let a user or admin update" do
        login(user)
        controller.stub(:current_user).and_return(users(user))
        put :update, :id => 'arthur', :user => {:bio => 'a little more about me'}
        response.should redirect_to(edit_user_path(users(:arthur)))
      end
    end
    
    it "should let a user upload a new photo" do 
      login(:arthur)
      post :attach_pic, :id => users(:arthur).login, :pic => {:pic => fixture_file_upload('images/jeffdoessudara.jpg','image/jpeg')}
      flash[:ok].should be_present
      response.should redirect_to(edit_user_path(users(:arthur)))
    end
    
    it "should not let a user upload a new photo for another user" do 
      login(:arthur)
      post :attach_pic, :id => users(:sudara).login, :pic => {:pic => fixture_file_upload('images/jeffdoessudara.jpg','image/jpeg')}
      response.should redirect_to('/login')
    end
    
    it "should let a user change their login" do 
      login(:arthur)
      put :update, :id => 'arthur', :user => {:login => 'arthursaurus'}
      flash[:error].should_not be_present
      response.should be_redirect
      User.where(:login => 'arthursaurus').count.should == 1
    end
    
    it 'should not let a user change login to login that exists' do 
      login(:arthur)
      put :update, :id => 'arthur', :user => {:login => 'sudara'}
      flash[:error].should be_present
      User.where(:login => 'sudara').count.should == 1
    end
  
    it "should not let any old user edit" do
      login(:arthur)
      controller.stub(:current_user).and_return(users(:arthur))
      post :edit, :id => 'sudara'
      response.should_not be_success
    end
  
    it "should not let any old user update" do
      login(:arthur)
      controller.stub(:current_user).and_return(users(:arthur))
      put :update,  :id => 'sudara', :user => { :bio => 'a little more about me' }
      response.should_not be_success
    end
  
    it "should not let a logged out user edit" do
      logout
      post :edit, :user_id => 'arthur'
      response.should_not be_success
    end
  
    it 'should deliver an rss feed for any user, to anyone' do
      get :show, :id => 'sudara', :format => 'rss'
      response.should be_success
    end
  end
  
  context "favoriting" do
    subject { get :toggle_favorite, :asset_id => 1 }
    it 'should let a user favorite a track' do 
      login(:arthur)    
      expect { subject }.to change{ Track.count }.by(1) 
      users(:arthur).tracks.favorites.collect(&:asset).should include(Asset.find(1))
      response.should be_success
    end
    
    it 'should let a user unfavorite a track' do 
      login(:arthur)
      expect { subject }.to change{ Track.count }.by(1) 
      get :toggle_favorite, :asset_id => 1  # toggle again
      users(:arthur).tracks.favorites.collect(&:asset).should_not include(Asset.find(1))
      response.should be_success
    end
    
    it 'should not let a user mess with another users favs' do
      
    end
  end
  
  context "sudo" do 
    it "should not let a normal user sudo" do
      controller.session[:return_to] = '/users'
      login(:arthur)
      get :sudo, :id => 'sudara'
      flash[:ok].should_not be_present
      response.should redirect_to '/'
    end
  
    it "should let an admin user sudo" do
      login(:sudara)
      controller.session[:return_to] = '/users'
      get :sudo, :id => 'arthur'
      flash[:ok].should be_present
      controller.session["user_credentials"].should == users(:arthur).persistence_token 
      response.should redirect_to '/users'
    end
    
    it "should let an sudo'd user return to their admin account" do
      login(:arthur)
      controller.session[:return_to] = '/users'
      controller.session[:sudo] = 1
      get :sudo, :id => 'arthur'
      flash[:ok].should be_present
      controller.session["user_credentials"].should == users(:sudara).persistence_token 
      response.should redirect_to '/users'
    end
  end
  
  context "last request at" do 
    it "should touch last_request_at when logging in" do 
      # Authlogic does this by default, which fucks things up
      expect { login(:arthur) }.to change{ users(:arthur).last_request_at}
    end
    
    # it "should touch last_request_at when doing anything" do
    #   Timecop.travel(12.minute.ago)
    #   login(:arthur)
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
