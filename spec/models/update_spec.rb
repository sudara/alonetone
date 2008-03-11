require File.dirname(__FILE__) + '/../spec_helper'

describe Update do
  before(:each) do
    @update = Update.new
  end

  it "should be valid" do
    @update.should be_valid
  end
end
