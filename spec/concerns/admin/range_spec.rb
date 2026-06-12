require 'rails_helper'

RSpec.describe Admin::Range do
  let(:harness) do
    Class.new do
      def self.helper_method(*); end
      include Admin::Range
      attr_accessor :params, :session

      def initialize
        @params = {}
        @session = {}
      end
    end
  end

  def with_range(range)
    controller = harness.new
    controller.params = { range: range }
    controller
  end

  describe '#admin_bucket' do
    it 'buckets short ranges by day' do
      expect(with_range('7d').send(:admin_bucket)).to eq(:day)
      expect(with_range('30d').send(:admin_bucket)).to eq(:day)
    end

    it 'buckets a year by week and all-time by month' do
      expect(with_range('1y').send(:admin_bucket)).to eq(:week)
      expect(with_range('all').send(:admin_bucket)).to eq(:month)
    end

    it 'falls back to the default range bucket for unknown values' do
      expect(with_range('bogus').send(:admin_bucket)).to eq(:day)
    end
  end

  describe '#admin_range' do
    it 'returns nil (unbounded) for all-time' do
      expect(with_range('all').send(:admin_range)).to be_nil
    end

    it 'returns a bounded range for a finite window' do
      expect(with_range('7d').send(:admin_range)).to be_a(Range)
    end
  end
end
