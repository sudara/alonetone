require "rails_helper"

RSpec.describe TopicsController, 'basics', type: :controller do
  fixtures :forums, :topics, :posts, :users


  def create_topic
    post :create, :forum_id => 'testforum', :topic => {:title => 'howdy', :body => '.'}
  end

  it "should not allow a post from a guest user" do
    expect {create_topic}.not_to change{ Topic.count }
    expect(response).to be_redirect
  end

  it "should allow a post from a logged in user" do
    login(:arthur)
    expect{ create_topic }.to change{ Topic.count }.by(1)
    expect(response).to be_redirect
  end
end
