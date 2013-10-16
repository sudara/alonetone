require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  
  fixtures :users, :assets
  
  context "basics" do 
    it 'should search assets by name / filename and return results' do
      get :index, :query => 'Song1'
      response.should be_success
      assigns(:assets).should include(assets(:valid_mp3))
    end
    
    it 'should not return results when search term is empty' do
      get :index
      response.should be_success
      flash[:error].should be_present
      assigns(:assets).should_not be_present
    end
  end
  
 
end
