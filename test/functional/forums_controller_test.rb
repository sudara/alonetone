require 'test_helper'

class ForumsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:forums)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_forum
    assert_difference('Forum.count') do
      post :create, :forum => { }
    end

    assert_redirected_to forum_path(assigns(:forum))
  end

  def test_should_show_forum
    get :show, :id => forums(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => forums(:one).id
    assert_response :success
  end

  def test_should_update_forum
    put :update, :id => forums(:one).id, :forum => { }
    assert_redirected_to forum_path(assigns(:forum))
  end

  def test_should_destroy_forum
    assert_difference('Forum.count', -1) do
      delete :destroy, :id => forums(:one).id
    end

    assert_redirected_to forums_path
  end
end
