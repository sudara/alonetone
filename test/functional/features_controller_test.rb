require 'test_helper'

class FeaturesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:features)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_feature
    assert_difference('Feature.count') do
      post :create, :feature => { }
    end

    assert_redirected_to feature_path(assigns(:feature))
  end

  def test_should_show_feature
    get :show, :id => features(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => features(:one).id
    assert_response :success
  end

  def test_should_update_feature
    put :update, :id => features(:one).id, :feature => { }
    assert_redirected_to feature_path(assigns(:feature))
  end

  def test_should_destroy_feature
    assert_difference('Feature.count', -1) do
      delete :destroy, :id => features(:one).id
    end

    assert_redirected_to features_path
  end
end
