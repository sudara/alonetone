require File.dirname(__FILE__) + '/../spec_helper'

describe AssetsController do
  fixtures :assets, :users
  
  it 'should accept a mp3 extension and redirect to the amazon url' do
    request.env["HTTP_ACCEPT"] = "audio/mpeg" 
    get :show, :id => 'song1', :login => users(:sudara).login, :format => 'mp3'
    response.should redirect_to(assets(:valid_mp3).public_mp3)
  end
  
  it 'should have a landing page' do
    get :show, :id => 'song1', :login => users(:sudara).login
    response.should be_success
  end

end
