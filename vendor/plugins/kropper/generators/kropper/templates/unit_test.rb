require File.dirname(__FILE__) + '/../test_helper'

class <%= class_name %>Test < Test::Unit::TestCase
  fixtures :<%= table_name %>

  def test_should_create_<%= file_name %>
    # ...
  end
end
