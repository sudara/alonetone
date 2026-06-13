require 'rails_helper'

RSpec.describe AdminHelper, type: :helper do
  describe '#admin_compact_number' do
    it 'formats totals compactly for admin cards' do
      expect(helper.admin_compact_number(999)).to eq('999')
      expect(helper.admin_compact_number(40_000)).to eq('40k')
      expect(helper.admin_compact_number(43_100)).to eq('43.1k')
      expect(helper.admin_compact_number(1_200_000)).to eq('1.2M')
    end
  end
end
