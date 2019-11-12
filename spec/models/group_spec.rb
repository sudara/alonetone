# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group do
  it 'should use its permalink as param' do
    expect(groups(:microwave).permalink).to eq(groups(:microwave).to_param)
  end

  describe 'slug' do
    let(:name) { 'The Wellfair' }
    let(:slug) { Slug.generate(name) }

    it 'updates when the name changes' do
      group = Group.new(name: name)
      expect(group.permalink).to eq(slug)
    end

    it 'saves the permalink after creation' do
      group = Group.create!(name: name, description: 'Not blank')
      expect(group.reload.permalink).to eq(slug)
    end

    it 'updates after name update' do
      group = groups(:microwave)
      group.update(name: name)
      expect(group.reload.permalink).to eq(slug)
    end

    it 'increments the slug in case of a collision' do
      existing = groups(:microwave)
      group = Group.create!(name: existing.name, description: 'Not blank')
      expect(group.reload.permalink).to eq('microwave-2')
    end
  end
end
