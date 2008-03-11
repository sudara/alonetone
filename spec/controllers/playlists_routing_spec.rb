require File.dirname(__FILE__) + '/../spec_helper'

describe PlaylistsController, 'routes' do
  
  it 'should generate and recognize friendly routes for playlists(based on permalinks)' do
    route_for(:controller => 'playlists', :action => 'show', :id => 'owp', :login => 'sudara').should == '/sudara/playlists/owp'
    params_from(:get, '/sudara/playlists/owp').should == {:controller => 'playlists', :action => 'show', :id => 'owp', :login => 'sudara'}
  end
  
  it 'should identify playlists by id and route the edit link appropriately' do 
    route_for(:controller => 'playlists', :action => 'edit', :id => '1', :login => 'sudara').should == '/sudara/playlists/1/edit'
    params_from(:get, '/sudara/playlists/1/edit').should == {:controller => 'playlists', :action => 'edit', :id => '1', :login => 'sudara'}
  end
  
  
  
end
