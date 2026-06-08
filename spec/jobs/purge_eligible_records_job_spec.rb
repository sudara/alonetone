require 'rails_helper'

RSpec.describe PurgeEligibleRecordsJob do
  it 'permanently destroys accounts soft-deleted more than 30 days ago' do
    user = users(:arthur)
    user.update_columns(deleted_at: 40.days.ago)

    described_class.new.perform

    expect(User.with_deleted.exists?(user.id)).to be(false)
  end

  it 'leaves recently soft-deleted accounts alone' do
    user = users(:arthur)
    user.update_columns(deleted_at: 5.days.ago)

    described_class.new.perform

    expect(User.with_deleted.exists?(user.id)).to be(true)
  end
end
