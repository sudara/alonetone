require "rails_helper"

RSpec.describe Listen, type: :model do
  describe "soft deletion" do
    it "soft deletes" do
      expect do
        Listen.all.map(&:soft_delete)
      end.not_to change { Listen.unscoped.count }
    end

    it "changes scope" do
      original_count = Listen.count
      expect do
        Listen.all.map(&:soft_delete)
      end.to change { Listen.count }.from(original_count).to(0)
    end
  end
end
