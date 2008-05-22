require 'test_helper'

class SourceFilesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:source_files)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_source_file
    assert_difference('SourceFile.count') do
      post :create, :source_file => { }
    end

    assert_redirected_to source_file_path(assigns(:source_file))
  end

  def test_should_show_source_file
    get :show, :id => source_files(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => source_files(:one).id
    assert_response :success
  end

  def test_should_update_source_file
    put :update, :id => source_files(:one).id, :source_file => { }
    assert_redirected_to source_file_path(assigns(:source_file))
  end

  def test_should_destroy_source_file
    assert_difference('SourceFile.count', -1) do
      delete :destroy, :id => source_files(:one).id
    end

    assert_redirected_to source_files_path
  end
end
