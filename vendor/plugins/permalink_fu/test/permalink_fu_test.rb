require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/permalink_fu')

class FauxColumn < Struct.new(:limit)
end

class BaseModel
  def self.columns_hash
    @columns_hash ||= {'permalink' => FauxColumn.new(100)}
  end

  include PermalinkFu
  attr_accessor :id
  attr_accessor :title
  attr_accessor :extra
  attr_reader   :permalink
  attr_accessor :foo

  class << self
    attr_accessor :validation
  end
  
  def self.generated_methods
    @generated_methods ||= []
  end
  
  def self.primary_key
    :id
  end
  
  def self.logger
    nil
  end
  
  # ripped from AR
  def self.evaluate_attribute_method(attr_name, method_definition, method_name=attr_name)

    unless method_name.to_s == primary_key.to_s
      generated_methods << method_name
    end

    begin
      class_eval(method_definition, __FILE__, __LINE__)
    rescue SyntaxError => err
      generated_methods.delete(attr_name)
      if logger
        logger.warn "Exception occurred during reader method compilation."
        logger.warn "Maybe #{attr_name} is not a valid Ruby identifier?"
        logger.warn "#{err.message}"
      end
    end
  end

  def self.exists?(*args)
    false
  end

  def self.before_validation(method)
    self.validation = method
  end

  def validate
    send self.class.validation
    permalink
  end
  
  def new_record?
    @id.nil?
  end
  
  def write_attribute(key, value)
    instance_variable_set "@#{key}", value
  end
end

class MockModel < BaseModel
  def self.exists?(conditions)
    if conditions[1] == 'foo'   || conditions[1] == 'bar' || 
      (conditions[1] == 'bar-2' && conditions[2] != 2)
      true
    else
      false
    end
  end

  has_permalink :title
end

class ScopedModel < BaseModel
  def self.exists?(conditions)
    if conditions[1] == 'foo' && conditions[2] != 5
      true
    else
      false
    end
  end

  has_permalink :title, :scope => :foo
end

class IfProcConditionModel < BaseModel
  has_permalink :title, :if => Proc.new { |obj| false }
end

class IfMethodConditionModel < BaseModel
  has_permalink :title, :if => :false_method
  
  def false_method; false; end
end

class IfStringConditionModel < BaseModel
  has_permalink :title, :if => 'false'
end

class UnlessProcConditionModel < BaseModel
  has_permalink :title, :unless => Proc.new { |obj| false }
end

class UnlessMethodConditionModel < BaseModel
  has_permalink :title, :unless => :false_method
  
  def false_method; false; end
end

class UnlessStringConditionModel < BaseModel
  has_permalink :title, :unless => 'false'
end

class MockModelExtra < BaseModel
  has_permalink [:title, :extra]
end

class PermalinkFuTest < Test::Unit::TestCase
  @@samples = {
    'This IS a Tripped out title!!.!1  (well/ not really)' => 'this-is-a-tripped-out-title-1-well-not-really',
    '////// meph1sto r0x ! \\\\\\' => 'meph1sto-r0x',
    'āčēģīķļņū' => 'acegiklnu',
    '中文測試 chinese text' => 'chinese-text',
    '中文測試' => 'untitled' # the more common scenario with foreign char sets (no english)
  }

  @@extra = { 'some-)()()-ExtRa!/// .data==?>    to \/\/test' => 'some-extra-data-to-test' }

  def test_should_escape_permalinks
    @@samples.each do |from, to|
      assert_equal to, PermalinkFu.escape(from)
    end
  end
  
  def test_should_escape_activerecord_model
    @a = MockModel.new
    @@samples.each do |from, to|

      @a.title = from; @a.permalink = nil
      assert_equal to, @a.validate
    end
  end

  def test_multiple_attribute_permalink
    @m = MockModelExtra.new
    @@samples.each do |from, to|
      @@extra.each do |from_extra, to_extra|
        @m.title = from; @m.extra = from_extra; @m.permalink = nil
        assert_equal "#{to}-#{to_extra}", @m.validate
      end
    end
  end
  
  def test_should_create_unique_permalink
    @m = MockModel.new
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo-2', @m.permalink
    
    @m.permalink = 'bar'
    @m.validate
    assert_equal 'bar-3', @m.permalink
  end
  
  def test_should_not_check_itself_for_unique_permalink
    @m = MockModel.new
    @m.id = 2
    @m.permalink = 'bar-2'
    @m.validate
    assert_equal 'bar-2', @m.permalink
  end
  
  def test_should_create_unique_scoped_permalink
    @m = ScopedModel.new
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo-2', @m.permalink

    @m.foo = 5
    @m.permalink = 'foo'
    @m.validate
    assert_equal 'foo', @m.permalink
  end
  
  def test_should_limit_permalink
    @old = MockModel.columns_hash['permalink'].limit
    MockModel.columns_hash['permalink'].limit = 2
    @m   = MockModel.new
    @m.title = 'BOO'
    assert_equal 'bo', @m.validate
  ensure
    MockModel.columns_hash['permalink'].limit = @old
  end
  
  def test_should_limit_unique_permalink
    @old = MockModel.columns_hash['permalink'].limit
    MockModel.columns_hash['permalink'].limit = 3
    @m   = MockModel.new
    @m.title = 'foo'
    assert_equal 'f-2', @m.validate
  ensure
    MockModel.columns_hash['permalink'].limit = @old
  end
  
  def test_should_abide_by_if_proc_condition
    @m = IfProcConditionModel.new
    @m.title = 'dont make me a permalink'
    @m.validate
    assert_nil @m.permalink
  end
  
  def test_should_abide_by_if_method_condition
    @m = IfMethodConditionModel.new
    @m.title = 'dont make me a permalink'
    @m.validate
    assert_nil @m.permalink
  end
  
  def test_should_abide_by_if_string_condition
    @m = IfStringConditionModel.new
    @m.title = 'dont make me a permalink'
    @m.validate
    assert_nil @m.permalink
  end
  
  def test_should_abide_by_unless_proc_condition
    @m = UnlessProcConditionModel.new
    @m.title = 'make me a permalink'
    @m.validate
    assert_not_nil @m.permalink
  end
  
  def test_should_abide_by_unless_method_condition
    @m = UnlessMethodConditionModel.new
    @m.title = 'make me a permalink'
    @m.validate
    assert_not_nil @m.permalink
  end
  
  def test_should_abide_by_unless_string_condition
    @m = UnlessStringConditionModel.new
    @m.title = 'make me a permalink'
    @m.validate
    assert_not_nil @m.permalink
  end
end
