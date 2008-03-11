require File.dirname(__FILE__) + '/../test_helper'
require '<%= controller_file_name %>_controller'

# Re-raise errors caught by the controller.
class <%= controller_class_name %>Controller; def rescue_action(e) raise e end; end

class <%= controller_class_name %>ControllerTest < Test::Unit::TestCase
  fixtures :<%= table_name %>

  def setup
    @controller = <%= controller_class_name %>Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_list_all_<%= file_name.pluralize %>
    # TODO
  end

  def test_should_show_upload_new_<%= file_name %>_form
    # TODO
  end

  def test_should_create_new_<%= file_name %>
    # TODO
  end

  def test_should_show_<%= file_name %>
    # TODO
  end

  def test_should_destroy_<%= file_name %>
    # TODO
  end

  def test_should_show_kropper
    # TODO
  end

  def test_should_crop_<%= file_name %>
    # TODO
  end

end
