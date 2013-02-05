# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserSessionsController do
  it "should successfuly login" do
    post :create, :login => 'arthur', :password => 'test'
    response.should be_logged_in 
  end

  it "should redirect to user's home after login" do
    session[:return_to] = "/session/back"
    post :create, :login => 'arthur', :password => 'test'
    response.should redirect_to('http://test.host/session/back')
    response.should be_logged_in
  end
  

  it "should not login a user with a bad password" do
    post :create, :login => 'arthur', :password => 'bad password'
    response.should_not be_logged_in
  end

  it "should log out when requested" do
    login_as :arthur
    post :destroy
    response.should redirect_to('http://test.host/')
    response.should_not be_logged_in
  end

  it 'should delete users cookie on logout' do
    login_as :arthur
    post :destroy
    response.cookies["auth_token"].should be_empty
  end

  it "should always remember user" do
    post :create, :login => 'arthur', :password => 'test'
    response.cookies["auth_token"].should_not be_empty
  end
end
