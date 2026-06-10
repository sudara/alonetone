require 'rails_helper'

RSpec.describe PurgeListensByIpJob do
  it 'deletes every listen from the ip and decrements the asset counter cache' do
    asset = assets(:valid_mp3)
    3.times { asset.listens.create!(track_owner: asset.user, ip: '198.51.100.7') }

    expect { described_class.new.perform('198.51.100.7') }
      .to change { asset.reload.listens_count }.by(-3)
    expect(Listen.with_deleted.where(ip: '198.51.100.7')).to be_empty
  end

  it 'decrements the track owner listens_count counter' do
    owner = users(:arthur)
    asset = assets(:valid_arthur_mp3)
    3.times { asset.listens.create!(track_owner: owner, ip: '198.51.100.9') }

    expect { described_class.new.perform('198.51.100.9') }
      .to change { owner.reload.listens_count }.by(-3)
  end

  it 'only touches counters for the purged ip' do
    asset = assets(:valid_mp3)
    other = assets(:valid_arthur_mp3)
    2.times { asset.listens.create!(track_owner: asset.user, ip: '198.51.100.13') }
    other.listens.create!(track_owner: other.user, ip: '198.51.100.99')

    described_class.new.perform('198.51.100.13')

    expect(Listen.where(ip: '198.51.100.99').count).to eq(1)
    expect(other.reload.listens_count).to be > 0
  end

  it 'decrements counters for soft-deleted listens it deletes' do
    asset = assets(:valid_mp3)
    3.times { asset.listens.create!(track_owner: asset.user, ip: '198.51.100.15') }
    Listen.where(ip: '198.51.100.15').update_all(deleted_at: Time.current)

    expect { described_class.new.perform('198.51.100.15') }
      .to change { asset.reload.listens_count }.by(-3)
    expect(Listen.with_deleted.where(ip: '198.51.100.15')).to be_empty
  end

  it 'keeps counters correct when the purge spans multiple batches' do
    stub_const('PurgeListensByIpJob::BATCH_SIZE', 2)
    asset = assets(:valid_mp3)
    5.times { asset.listens.create!(track_owner: asset.user, ip: '198.51.100.17') }

    expect { described_class.new.perform('198.51.100.17') }
      .to change { asset.reload.listens_count }.by(-5)
    expect(Listen.with_deleted.where(ip: '198.51.100.17')).to be_empty
  end

  it 'is a no-op for a blank ip' do
    expect { described_class.new.perform('') }.not_to change(Listen, :count)
  end

  it 'recounts soft-deleted assets and owners without raising' do
    asset = assets(:valid_mp3)
    3.times { asset.listens.create!(track_owner: asset.user, ip: '198.51.100.11') }
    asset.soft_delete
    asset.user.soft_delete

    expect { described_class.new.perform('198.51.100.11') }.not_to raise_error
    expect(Listen.with_deleted.where(ip: '198.51.100.11')).to be_empty
  end
end
