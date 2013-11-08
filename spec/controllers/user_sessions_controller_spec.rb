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
    session[:return_to] = nil
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    response.should redirect_to('http://test.host/arthur')    
  end
  
  it "should redirect to last page viewed after login" do
    activate_authlogic
    session[:return_to] = '/forums'
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    response.should redirect_to('http://test.host/forums')    
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

  it "should touch last_request_at when logging in" do 
    # Authlogic does this by default, which fucks things up
    expect { login(:arthur) }.to change{ users(:arthur).last_request_at}
  end
  
  it "should not touch updated_at when logging in" do 
    # Authlogic does this by default, which fucks things up
    expect { login(:arthur) }.to_not change{ users(:arthur).updated_at}
  end
  
end
