# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserSessionsController do
  fixtures :users

  it "should successfuly login" do
    setup_authlogic
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    controller.session["user_credentials"].should == users(:arthur).persistence_token 
    assigns(:user_session).login.should == users(:arthur).login
  end

  it "should always remember user" do
    setup_authlogic
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    assigns(:user_session).login.should == users(:arthur).login
  end
  
  it "should redirect to user's home after login" do
    setup_authlogic
    session[:return_to] = "/session/back"
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    response.should redirect_to('http://test.host/arthur')    
  end
  

  it "should not login a user with a bad password" do
    setup_authlogic
    post :create, :user_session => { :login => 'arthur', :password => 'bad password' }
    controller.session["user_credentials"].should_not be_present
  end

  it "should log out when requested" do
    login(users(:arthur))
    post :destroy
    response.should redirect_to('http://test.host/login')
    controller.session["user_credentials"].should_not be_present
  end

  it 'should delete users cookie on logout' do
    login(users(:arthur))
    post :destroy
    assigns(:user_session).should_not be_present
  end

end
