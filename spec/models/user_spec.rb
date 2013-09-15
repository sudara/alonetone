# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  fixtures :users

  it "should be valid with email, login and password" do
    new_user.should be_valid
    users(:sudara).should be_valid
  end
  
  it "can be an admin" do
    users(:sudara).should be_admin
  end
  
  it "can be a mod" do 
    users(:sandbags).should be_moderator
  end
  
  it "should not require a bio on update" do
    @user = new_user
    @user.save
    @user.save
    @user.should be_valid
  end
  
  it "is considered active when persible token doesn't exist" do
    users(:arthur).should be_active
  end
  
  it "can be not yet activated" do
    users(:not_activated).should_not be_active
  end
  
  
  protected
    def new_user(options = {})
      User.new({ :email => 'new@user.com', :login => 'newuser', :password => 'quire451', :password_confirmation => 'quire451' }.merge(options))
    end
end

