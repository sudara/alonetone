# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  
  fixtures :users
  
  context 'creating' do   
    it "should successfully post to users/create" do
      create_user
      response.should redirect_to("/login")
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
    
    
  end
end

describe UsersController, "profile" do
  fixtures :users, :assets
  [:sudara, :arthur].each do |user|
    it "should let a user or admin" do
      login(user)
      controller.stub(:current_user).and_return(users(user))
      post :edit, :id => 'arthur'
      response.should be_success
    end
  
    it "should let a user or admin update" do
      login(user)
      controller.stub(:current_user).and_return(users(user))
      put :update, :id => 'arthur', :user => {:id => 'arthur', :bio => 'a little more about me'}
      response.should redirect_to(edit_user_path(users(:arthur)))
    end
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
    put :update,  :id => 'sudara', :user => {:id => 'sudara', :bio => 'a little more about me'}    
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
  
end

def create_user(options = {})
  Timecop.travel(1.day.ago)
  post :create, :user => { :login => 'quire', :email => 'quire@example.com', :password => 'quire12345', :password_confirmation => 'quire12345'}.merge(options)
  Timecop.return
end
