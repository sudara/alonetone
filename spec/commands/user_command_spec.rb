require 'rails_helper'

RSpec.describe UserCommand do
  describe 'cached comment counts' do
    it "decrements the receiver's count when a commenter is soft-deleted, and restores it" do
      commenter = users(:arthur)
      asset = assets(:valid_mp3)
      receiver = asset.user
      Comment.create!(commentable: asset, commenter: commenter, body: 'hi from arthur')

      expect { described_class.new(commenter).soft_delete_with_relations }
        .to change { receiver.reload.comments_count }.by(-1)
        .and change { asset.reload.comments_count }.by(-1)

      expect { described_class.new(commenter.reload).restore_with_relations }
        .to change { receiver.reload.comments_count }.by(1)
        .and change { asset.reload.comments_count }.by(1)
    end
  end
end
