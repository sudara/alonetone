require "rails_helper"

RSpec.describe Comment, type: :model do
  fixtures :comments, :users, :assets

  let(:new_comment) { assets(:valid_mp3).comments.new(:body => 'test',:commentable_type => 'Asset', :commentable_id => '1') }

  context "validation" do
    it "should be valid when made by user" do
      expect(comments(:valid_comment_on_asset_by_user)).to be_valid
    end

    it "should be valid when made by guest" do
      expect(comments(:valid_comment_on_asset_by_guest)).to be_valid
    end

    it "should be valid even if spam" do
      expect(comments(:spam_comment_on_asset_by_guest)).to be_valid
    end

    it "should be valid without a commenter_id" do
      expect(comments(:comment_on_update)).to be_valid
    end

    it "should be able to be private as user" do
      expect(comments(:private_comment_on_asset_by_user)).to be_valid
    end

    it "should be able to be private as guest" do
      expect(comments(:private_comment_on_asset_by_guest)).to be_valid
    end
  end

  context "saving" do
    it "should save with just a body and a commentable" do
      expect(new_comment.save).to be_truthy
    end

    it "should store user_id when commenting on an asset" do
      expect(new_comment.save).to be_truthy
      expect(new_comment.user_id).to eq(assets(:valid_mp3).user_id)
    end

    it "should not save a dupe (same content/ip)" do
      body = comments(:valid_comment_on_asset_by_user).body
      ip = comments(:valid_comment_on_asset_by_user).remote_ip
      comment2 = Comment.new(:body => body, :remote_ip => ip, :commentable_type => 'Asset', :commentable_id => '1')
      expect(comment2.save).to be_falsey
    end

    it "should deliver a mail to the user if it was an asset comment" do
      expect {new_comment.save}.to change{ActionMailer::Base.deliveries.size}.by(1)
    end

    it "should not be delivering mail for non-asset comments" do
      comment = Comment.new(:body => "awesome blog post", :commentable_type => 'Update', :commentable_id => 1)
      expect {comment.save}.not_to change{ActionMailer::Base.deliveries.size}

    end
  end

  context "private and guests" do


  end

  context "spam" do

    it "should ask akismet if there is spam" do
      comment = new_comment
      #comment.should_receive(:spam?)
      expect(Rakismet).to receive(:akismet_call)
      expect(comment.save).to be_truthy
      expect(comment.is_spam).to be_falsey
    end
  end

end

