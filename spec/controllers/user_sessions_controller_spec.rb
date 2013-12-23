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
  
  # this is in authlogic, needs testing since we modify it (see users_controller_spec)
  it "should update IP and last_request_at" do
    Timecop.freeze(1.hour.ago) do
      request.env['REMOTE_ADDR'] = '10.1.1.1'
      login(:arthur)
      controller.session["user_credentials"].should == users(:arthur).persistence_token 
      expect(users(:arthur).current_login_ip).to eq('10.1.1.1')
      expect(users(:arthur).last_request_at).to eq(Time.now)
    end
  end
  
end
