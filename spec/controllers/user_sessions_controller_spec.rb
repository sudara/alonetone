require "rails_helper"

RSpec.describe UserSessionsController, type: :controller do
  fixtures :users

  it "should successfully login with alonetone login" do
    activate_authlogic
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    expect(controller.session["user_credentials"]).to eq(users(:arthur).persistence_token)
    expect(assigns(:user_session).login).to eq(users(:arthur).login)
  end

  it "should successfully login with email" do
    activate_authlogic
    expect(controller.session["user_credentials"]).to eq(nil)
    post :create, :user_session => { :login => 'arthur@example.com', :password => 'test'}
    expect(controller.session["user_credentials"]).to eq(users(:arthur).persistence_token)
    #assigns(:user_session).login.should == users(:arthur).login
  end

  it "should always remember user" do
    activate_authlogic
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    expect(assigns(:user_session).login).to eq(users(:arthur).login)
  end

  it "should redirect to user's home after login" do
    activate_authlogic
    session[:return_to] = nil
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    expect(response).to redirect_to('http://test.host/arthur')
  end

  it "should redirect to last page viewed after login" do
    activate_authlogic
    session[:return_to] = '/forums'
    post :create, :user_session => { :login => 'arthur', :password => 'test'}
    expect(response).to redirect_to('http://test.host/forums')
  end

  it "should not login a user with a bad password" do
    activate_authlogic
    post :create, :user_session => { :login => 'arthur', :password => 'bad password' }
    expect(controller.session["user_credentials"]).not_to be_present
  end

  it "should log out when requested" do
    login(:arthur)
    post :destroy
    expect(response).to redirect_to('http://test.host/login')
  end

  it 'should delete session cookie on logout' do
    login(:arthur)
    post :destroy
    expect(controller.session["user_credentials"]).not_to be_present
  end

  # this is in authlogic, needs testing since we modify it (see users_controller_spec)
  it "should update IP and last_request_at" do
    Timecop.freeze(1.hour.ago) do
      request.env['REMOTE_ADDR'] = '10.1.1.1'
      login(:arthur)
      expect(controller.session["user_credentials"]).to eq(users(:arthur).persistence_token)
      expect(users(:arthur).current_login_ip).to eq('10.1.1.1')
      expect(users(:arthur).last_request_at).to eq(Time.now)
    end
  end

end
