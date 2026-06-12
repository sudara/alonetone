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
end
