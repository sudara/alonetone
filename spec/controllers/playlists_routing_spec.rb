# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe PlaylistsController, 'routes', :type => :routing do
  
  it 'should generate and recognize friendly routes for playlists(based on permalinks)' do
    #route_for(:controller => 'playlists', :action => 'show', :id => 'owp', :user_id => 'sudara').should == '/sudara/playlists/owp'
    expect(:get => '/sudara/playlists/owp').to route_to({:controller => 'playlists', :action => 'show', :id => 'owp', :user_id => 'sudara'})
  end
  
  it 'should identify playlists by id and route the edit link appropriately' do 
    #route_for(:controller => 'playlists', :action => 'edit', :id => '1', :user_id => 'sudara').should == '/sudara/playlists/1/edit'
    expect(:get => '/sudara/playlists/1/edit').to route_to({:controller => 'playlists', :action => 'edit', :id => '1', :user_id => 'sudara'})
  end
  
  
  
end
