require File.dirname(__FILE__) + '/../test_helper'

class UserReportsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:user_reports)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_user_reports
    assert_difference('UserReports.count') do
      post :create, :user_reports => { }
    end

    assert_redirected_to user_reports_path(assigns(:user_reports))
  end

  def test_should_show_user_reports
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_user_reports
    put :update, :id => 1, :user_reports => { }
    assert_redirected_to user_reports_path(assigns(:user_reports))
  end

  def test_should_destroy_user_reports
    assert_difference('UserReports.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to user_reports_path
  end
end
