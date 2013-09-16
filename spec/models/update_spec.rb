# -*- encoding : utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Update do
  fixtures :updates
  
  before(:each) do
    #@update = Update.new
  end

  it "should be valid and saveable" do
    updates(:valid).should be_valid
    updates(:valid).save.should == true
  end
end
