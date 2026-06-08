require 'rails_helper'

RSpec.describe PurgeListensByIpJob do
  it 'deletes every listen from the ip and resets the asset counter cache' do
    asset = assets(:valid_mp3)
    3.times { asset.listens.create!(track_owner: asset.user, ip: '198.51.100.7') }
    asset.reload
    expect(asset.listens.where(ip: '198.51.100.7').count).to eq(3)

    described_class.new.perform('198.51.100.7')

    expect(Listen.with_deleted.where(ip: '198.51.100.7')).to be_empty
    expect(asset.reload.listens_count).to eq(asset.listens.count)
  end

  it 'resets the track owner listens_count counter' do
    owner = users(:arthur)
    asset = assets(:valid_arthur_mp3)
    3.times { asset.listens.create!(track_owner: owner, ip: '198.51.100.9') }

    described_class.new.perform('198.51.100.9')

    expect(owner.reload.listens_count).to eq(owner.track_plays.count)
  end

  it 'is a no-op for a blank ip' do
    expect { described_class.new.perform('') }.not_to change(Listen, :count)
  end
end
