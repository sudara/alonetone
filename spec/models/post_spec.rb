require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  fixtures :forums, :topics, :posts, :users
    
  context "validation" do 
    it "should be valid" do
      posts(:post1).should be_valid
    end
  end
  
  context "relationships" do 
    it "should reach its topic" do 
      posts(:post1).topic.should be_present
    end
    
    it "should reach its forum" do 
      posts(:post1).forum.should be_present
    end
  end
end