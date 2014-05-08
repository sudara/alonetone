require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do
  fixtures :forums, :topics, :posts
    
  context "validation" do 
    it "should be valid" do
      topics(:topic1).should be_valid
    end
  end
  
  context "relationships" do 

    it "should reach its forum" do 
      topics(:topic1).forum.should be_present
    end
  end
end