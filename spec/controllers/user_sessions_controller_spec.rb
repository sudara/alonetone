# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserSessionsController do
  fixtures :users

  it "should successfuly login" do
    activate_authlogic
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    controller.session["user_credentials"].should == users(:arthur).persistence_token 
    assigns(:user_session).login.should == users(:arthur).login
  end

  it "should always remember user" do
    activate_authlogic
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    assigns(:user_session).login.should == users(:arthur).login
  end
  
  it "should redirect to user's home after login" do
    activate_authlogic
    session[:return_to] = "/session/back"
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    response.should redirect_to('http://test.host/arthur')    
  end
  

  it "should not login a user with a bad password" do
    activate_authlogic
    post :create, :user_session => { :login => 'arthur', :password => 'bad password' }
    controller.session["user_credentials"].should_not be_present
  end

  it "should log out when requested" do
    login(:arthur)
    post :destroy
    response.should redirect_to('http://test.host/login')
  end

  it 'should delete session cookie on logout' do
    login(:arthur)
    post :destroy
    controller.session["user_credentials"].should_not be_present
  end

end
