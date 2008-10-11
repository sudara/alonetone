require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  
  before(:each) do
    @user = new_user
  end

  it "should be valid" do
    @user.should be_valid
  end
  
  it "should require a bio on update" do
    @user.save
    @user.save
    @user.should_not be_valid
  end
  
  protected
    def new_user(options = {})
      User.new({ :email => 'new@user.com', :login => 'newuser', :password => 'quire451', :password_confirmation => 'quire451' }.merge(options))
    end
end

