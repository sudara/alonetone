require 'rails_helper'

RSpec.describe Assets::DestroyWithRelations do
  let(:asset) { assets(:asset_with_relations_for_soft_delete) }

  before :each do
    Assets::SoftDeleteRelations.new(asset: asset).call
    asset.soft_delete
  end

  subject { described_class.new(asset: asset) }

  before :each do
    subject.call
  end

  it "should destroy comments for realz" do
    # without reloading asset can still access ^ object's id
    expect(Comment.with_deleted.where(commentable_id: asset.id)).to eq([])
  end

  it "should destroy tracks for realz" do
    expect(Track.with_deleted.where(asset_id: asset.id)).to eq([])
  end

  it "should destroy listens for realz" do
    expect(Listen.with_deleted.where(asset_id: asset.id)).to eq([])
  end

  it "should destroy audio_feature for realz" do
    expect(AudioFeature.where(asset_id: asset.id)).to eq([])
  end

  it "should destroy asset itself for realz" do
    expect(Asset.where(id: asset.id)).to eq([])
  end
end