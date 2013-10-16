require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  fixtures :users, :assets, :playlists, :tracks

  context "validation" do
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
  end
  
  context "activation" do 
    it "is considered active when persishble token doesn't exist" do
      users(:arthur).should be_active
    end
  
    it "is not active when perishable token exists" do
      users(:not_activated).perishable_token.should be_present
      users(:not_activated).should_not be_active
    end
  
    it "can be activated and deactivated" do
      users(:not_activated).activate! 
      expect(users(:not_activated)).to be_active
      users(:not_activated).reset_perishable_token!
      users(:not_activated).should_not be_active 
    end
  end
  
  context "relations" do 
    it 'has tracks called assets' do 
      users(:arthur).assets.should be_present
    end
    
    it 'has a favorites playlist and tracks' do 
      # users(:arthur).favorites.should be_present
    end
  end
  
  
  protected
    def new_user(options = {})
      User.new({ :email => 'new@user.com', :login => 'newuser', :password => 'quire451', :password_confirmation => 'quire451' }.merge(options))
    end
end

