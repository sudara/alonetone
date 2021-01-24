# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MassInvite, type: :model do
  it 'sets a token after initialization' do
    expect(MassInvite.new.token).to_not be_empty
  end

  it 'uses its token as the request param' do
    mass_invite = MassInvite.new
    expect(mass_invite.to_param).to eq(mass_invite.token)
  end

  context 'scopes' do
    it 'orders mass invites by creation order' do
      last = Time.zone.now
      MassInvite.recent.each do |mass_invite|
        expect(mass_invite.created_at).to be < last
        last = mass_invite.created_at
      end
    end
  end

  context 'validation' do
    let(:valid_mass_invite) do
      MassInvite.new(name: 'One Song Per Year Challenge')
    end

    it 'should be valid with all required attributes' do
      expect(valid_mass_invite).to be_valid
    end

    it 'should not allow a blank name' do
      valid_mass_invite.name = ''
      expect(valid_mass_invite).not_to be_valid
      expect(valid_mass_invite.errors[:name]).to_not be_empty
    end

    it 'should not allow a blank token' do
      valid_mass_invite.token = ''
      expect(valid_mass_invite).not_to be_valid
      expect(valid_mass_invite.errors[:token]).to_not be_empty
    end
  end
end
