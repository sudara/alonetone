# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Slugs do
  context 'a slug' do
    let(:record) { Group.new }

    it 'returns all the configured slugs for the class' do
      expect(record.class.slugs).to eq(
        permalink: [:name, nil]
      )
    end

    it 'does not have a slug' do
      expect(record.permalink).to be_nil
    end

    it 'sets the slug when the source attribute changes' do
      record.name = 'The Bob Marshall Trio Experience'
      expect(record.permalink).to eq('the-bob-marshall-trio-experience')
    end

    it 'increments the slug when it already exists before save' do
      existing = groups(:microwave)
      record.name = existing.name
      record.description = 'Not blank'

      expect(record.permalink).to eq('microwave')
      record.save!
      expect(record.reload.permalink).to eq('microwave-2')
    end

    it 'does not change an existing slug when the source attribute does not change' do
      group = groups(:kliek)
      group.update(name: group.name)
      expect(group.permalink).to eq('dekliek')
    end
  end

  context 'a slug with a scope and default value' do
    let(:record) { Asset.new }

    it 'returns all the configured slugs for the class' do
      expect(record.class.slugs).to eq(
        permalink: [:title, :user_id]
      )
    end

    it 'has the default slug' do
      expect(record.permalink).to eq('untitled')
    end

    it 'sets the slug when the source attribute changes' do
      record.title = 'The Bob Marshall Trio Experience'
      expect(record.permalink).to eq('the-bob-marshall-trio-experience')
    end

    it 'increments the slug when it already exists before save' do
      existing = assets(:henri_willig_finest_cheese)
      record.title = existing.title
      record.user = users(:henri_willig)

      expect(record.permalink).to eq('manufacturer-of-the-finest-cheese')
      record.save!
      expect(record.reload.permalink).to eq('manufacturer-of-the-finest-cheese-2')
    end

    it 'does not increments the slug when it already exists outside of scope' do
      existing = assets(:henri_willig_finest_cheese)
      record.title = existing.title
      record.user = users(:william_shatner)

      expect(record.permalink).to eq('manufacturer-of-the-finest-cheese')
      record.save!
      expect(record.reload.permalink).to eq('manufacturer-of-the-finest-cheese')
    end

    it 'keeps the default when the source attribute becomes blank' do
      asset = assets(:henri_willig_finest_cheese)
      asset.title = ''
      expect(asset.permalink).to eq('untitled')
    end
  end
end
