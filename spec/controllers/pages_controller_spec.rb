require File.dirname(__FILE__) + '/../spec_helper'

describe PagesController do
  
  it "should have an about page that renders without errors" do 
    get :index
    response.should be_success
  end  
  
end
