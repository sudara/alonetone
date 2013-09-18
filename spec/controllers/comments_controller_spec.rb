# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  
  fixtures :users, :comments
  
  context "basics" do 
    it 'should allow anyone to view the comments index' do
      get :index
      response.should be_success
    end
  end
  
  context "private comments made by user" do 
    it "should be visible to private user viewing their own shit" do 
      login(:arthur)
      get :index, :login => 'arthur'
      assigns(:comments_made).should include(comments(:private_comment_on_asset_by_user))      
    end
    
    it "should be visible to admin" do 
      login(:sudara)
      get :index, :login => 'arthur'
      assigns(:comments_made).should include(comments(:private_comment_on_asset_by_user))
    end
    
    it "should be visible to mod" do 
      login(:sandbags)
      get :index, :login => 'arthur'
      assigns(:comments_made).should include(comments(:private_comment_on_asset_by_user))
    end
    
    
    it "should not be visible to guest" do 
      get :index, :login => 'arthur'
      assigns(:comments_made).should_not include(comments(:private_comment_on_asset_by_user))
    end 
    
    it "should not be visible to normal user" do 
      login(:joeblow)
      get :index, :login => 'arthur'
      assigns(:comments_made).should_not include(comments(:private_comment_on_asset_by_user))
    end
  end
  
  
  
  context "private comments on index" do 
  
    it "should be visible to admin" do 
      login(:sudara)
      get :index
      assigns(:comments).should include(comments(:private_comment_on_asset_by_guest))
    end
    
    it "should be visible to mod" do 
      login(:sandbags)
      get :index
      assigns(:comments).should include(comments(:private_comment_on_asset_by_guest))
    end
    
    
    it "should not be visible to guest" do 
      get :index
      assigns(:comments).should_not include(comments(:private_comment_on_asset_by_guest))
    end 
    
    it "should not be visible to normal user" do 
      login(:arthur)
      get :index
      assigns(:comments).should_not include(comments(:private_comment_on_asset_by_guest))
    end
    
  end
  
end
