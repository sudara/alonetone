require 'rails_helper'

RSpec.describe AssetCommand do
  describe '#destroy_with_relations' do
    it 'rolls back relation deletes when the asset destroy fails' do
      asset = assets(:valid_arthur_mp3)
      listen = asset.listens.create!(track_owner: asset.user)
      allow(asset).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new('failed', asset))

      expect { described_class.new(asset).destroy_with_relations }
        .to raise_error(ActiveRecord::RecordNotDestroyed)

      expect(Listen.with_deleted.exists?(listen.id)).to be(true)
    end
  end

  describe 'cached comment counts' do
    it 'decrements on soft delete and restores them, for the asset and its owner' do
      asset = assets(:valid_arthur_mp3)
      Comment.create!(commentable: asset, commenter: users(:sudara), body: 'great track')
      receiver = asset.user
      asset_live = asset.comments.where(is_spam: false).count
      receiver_live = asset.comments.where(is_spam: false, user_id: receiver.id).count

      expect { described_class.new(asset).soft_delete_with_relations }
        .to change { asset.reload.comments_count }.by(-asset_live)
        .and change { receiver.reload.comments_count }.by(-receiver_live)

      expect { described_class.new(asset.reload).restore_with_relations }
        .to change { asset.reload.comments_count }.by(asset_live)
        .and change { receiver.reload.comments_count }.by(receiver_live)
    end
  end
end
