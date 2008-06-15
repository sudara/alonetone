require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:topics)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_topic
    assert_difference('Topic.count') do
      post :create, :topic => { }
    end

    assert_redirected_to topic_path(assigns(:topic))
  end

  def test_should_show_topic
    get :show, :id => topics(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => topics(:one).id
    assert_response :success
  end

  def test_should_update_topic
    put :update, :id => topics(:one).id, :topic => { }
    assert_redirected_to topic_path(assigns(:topic))
  end

  def test_should_destroy_topic
    assert_difference('Topic.count', -1) do
      delete :destroy, :id => topics(:one).id
    end

    assert_redirected_to topics_path
  end
end
