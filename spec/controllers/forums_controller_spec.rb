require File.dirname(__FILE__) + '/../spec_helper'

describe ForumsController do
  fixtures :users
  
  it "should render index without errors" do 
    get :index
    response.should be_success
  end 
  
  it "should render index without errors for user" do 
    login(:arthur)
    get :index
    response.should be_success
  end   
  
end
