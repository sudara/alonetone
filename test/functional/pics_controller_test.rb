require File.dirname(__FILE__) + '/../test_helper'
require 'pics_controller'

# Re-raise errors caught by the controller.
class PicsController; def rescue_action(e) raise e end; end

class PicsControllerTest < Test::Unit::TestCase
  def setup
    @controller = PicsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:pics)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_pic
    assert_difference('Pic.count') do
      post :create, :pic => { }
    end

    assert_redirected_to pic_path(assigns(:pic))
  end

  def test_should_show_pic
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_pic
    put :update, :id => 1, :pic => { }
    assert_redirected_to pic_path(assigns(:pic))
  end

  def test_should_destroy_pic
    assert_difference('Pic.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to pics_path
  end
end
