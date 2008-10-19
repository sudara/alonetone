require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  
  it "should send user activation email after signup" do
    UserMailer.should_receive(:deliver_signup).with(an_instance_of(User))
    lambda do 
      create_user # posts 
    end.should change(User,:count).by(1)
  end

  it "should require login on signup" do
    create_user :login => nil 
    response.should be_success
    assigns(:user).should have_at_least(1).errors_on(:login)
  end

  it "should require password on signup" do
    create_user :password => nil 
    response.should be_success
    assigns(:user).should have_at_least(1).errors_on(:password)
  end

  it "should require password confirmation on signup" do
    create_user :password_confirmation => nil 
    response.should be_success
    assigns(:user).should have_at_least(1).errors_on(:password_confirmation)
  end

  it "should require email on signup" do
    create_user :email => nil 
    response.should be_success
    assigns(:user).should have_at_least(1).errors_on(:email)
  end

  it "should not activate with bullshit activation code" do
    get :activate, :activation_code => 123
    response.should_not be_success
  end

  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com', :password => 'quire12345', :password_confirmation => 'quire12345'}.merge(options)
  end
end

describe UsersController, "permissions" do
  fixtures :users, :assets
  integrate_views
  [:sudara, :arthur].each do |user|
    it "should let a user or admin edit their profile" do
      login_as(user)
      post :edit, :login => 'arthur'
      response.should be_success
    end
  
    it "should let a user or admin update their profile" do
      login_as(user)
      put :update, :user => {:login => 'arthur', :bio => 'a little more about me'}
      response.should be_success
    end
  end
  
  it "should not let any old user edit a profile" do
    login_as(:arthur)
    post :edit, :login => 'sudara'
    response.should_not be_success
  end
  
  it "should not let any old user update a profile" do
    login_as(:arthur)
    put :update, :id => 'sudara', :user => {:login => 'sudara', :bio => 'a little more about me'}    
    response.should_not be_success
  end
  
  it "should not let a logged out user edit a profile" do
    logout
    post :edit, :login => 'arthur'
    response.should_not be_success
  end
  
  it "should not let a normal user sudo" do
    login_as(:arthur)
    get :sudo, :id => 'sudara'
    response.should_not be_success
  end
  
  it "should let an admin user sudo" do
    request.env["HTTP_REFERER"] = '/users/blah'
    login_as(:sudara)
    get :sudo, :id => 'sudara'
    response.should redirect_to '/users/blah'
  end
  
  it 'should deliver an rss feed for any user, to anyone' do
    get :show, :id => 'sudara', :format => 'rss'
    response.should be_success
  end
  
end
