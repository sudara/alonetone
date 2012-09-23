# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe UpdatesController do
  
  fixtures :updates
  
  it "should not allow a normal user to edit an update" do
    login_as :arthur
    get :edit, :id => updates(:one)
    response.should_not be_success
  end
  
  it 'should not let a logged out user edit an update' do
    get :edit, :id => updates(:one)
    response.should_not be_success    
  end
  
  it 'should not let a guest update or destroy an update' do 
    put :update, :id => updates(:one), :title => 'change me'
    response.should_not be_success
  end
  
  it 'should allow anyone to view the updates index' do
    get :index
    response.should be_success
  end
  
  it "should allow an admin to edit an user report" do
    login_as :sudara
    get :edit, :id => updates(:one)
    response.should be_success
  end
  
  it "should not let a normal joe create a user report" do
    post :create, :title => 'new', :content => 'report'
    response.should_not be_success
  end


end
