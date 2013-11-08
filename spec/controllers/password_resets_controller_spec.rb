require File.dirname(__FILE__) + '/../spec_helper'

describe PasswordResetsController do
  
  fixtures :users
  
  context 'resetting' do   
    it "should error if the email provided doesn't exist" do 
      post :create, :email => "blah"
      response.should redirect_to(login_path)
      flash[:error].should be_present
    end
    
    it "should disallow logins after resetting" do 
      activate_authlogic
      post :create, :email => [users(:arthur).email]
      flash[:error].should_not be_present
      User.where(:login => 'arthur').first.perishable_token.should_not be_nil
      login(:arthur)
      controller.session["user_credentials"].should == nil # can't login
    end
    
    it 'should send an email with link to reset pass' do
      post :create, :email => [users(:arthur).email]
      ActionMailer::Base.deliveries.last.to.should == [users(:arthur).email]
    end
    
    it 'should render form to reset password given a decent token' do 
      post :create, :email => [users(:arthur).email]
      get :edit, :id => User.where(:login => 'arthur').first.perishable_token
      response.should be_success
      flash[:error].should_not be_present
    end
    
    it 'should not render form to reset password given some bullshit token' do
      get :edit, :id => 'oeuouoeu'
      response.should be_redirect
      flash[:error].should be_present
    end
    
    it 'should allow user to manually type in password and login user' do
      activate_authlogic
      post :create, :email => [users(:arthur).email]
      put :update, :id => User.where(:login => 'arthur').first.perishable_token, 
        :user => {:password => '123456', :password_confirmation => '123456'}
      response.should redirect_to('/arthur')
      User.where(:login => 'arthur').first.perishable_token.should be_nil
      controller.session["user_credentials"].should == users(:arthur).persistence_token # logged in
    end

    it 'should allow user to manually type in password and present edit again if passes do not match' do
      activate_authlogic
      post :create, :email => [users(:arthur).email]
      put :update, :id => User.where(:login => 'arthur').first.perishable_token, 
        :user => {:password => '123456', :password_confirmation => '1234567'}
      response.should redirect_to(edit_password_reset_path(User.where(:login => 'arthur').first.perishable_token))
      controller.session["user_credentials"].should == nil
    end    
  end
  
end