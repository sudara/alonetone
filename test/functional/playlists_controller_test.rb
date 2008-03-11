require File.dirname(__FILE__) + '/../test_helper'
require 'playlists_controller'

# Re-raise errors caught by the controller.
class PlaylistsController; def rescue_action(e) raise e end; end

class PlaylistsControllerTest < Test::Unit::TestCase
  fixtures :playlists

  def setup
    @controller = PlaylistsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:playlists)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_playlist
    assert_difference('Playlist.count') do
      post :create, :playlist => { }
    end

    assert_redirected_to playlist_path(assigns(:playlist))
  end

  def test_should_show_playlist
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_playlist
    put :update, :id => 1, :playlist => { }
    assert_redirected_to playlist_path(assigns(:playlist))
  end

  def test_should_destroy_playlist
    assert_difference('Playlist.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to playlists_path
  end
end
