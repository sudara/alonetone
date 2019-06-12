require "rails_helper"

RSpec.describe SoftDeletion do
  describe "scope" do
    it "should provide scope to display deleted records" do
      expect(User.only_deleted.count).to eq(1)
    end

    it "should provide scope to exclude deleted records" do
      expect(User.with_deleted.count).to eq(User.count + 1)
    end

    it "should exclude deleted records from default scope" do
      expect(User.all.count).to eq(User.with_deleted.count - 1)
    end
  end

  describe "soft deletion" do
    it "soft deletes" do
      expect do
        User.all.map(&:soft_delete)
      end.not_to change { User.unscoped.count }
    end

    it "changes scope" do
      original_count = User.count
      expect do
        User.all.map(&:soft_delete)
      end.to change { User.count }.from(original_count).to(0)
    end

    it "allows a check if record if soft deleted" do
      expect(users(:deleted_yesterday).deleted?).to eq(true)
      expect(users(:arthur).deleted?).to eq(false)
    end
  end

  describe "restore" do
    it "restores a record" do
      expect do
         User.with_deleted.map(&:restore)
      end.not_to change { User.unscoped.count }
    end

    it "changes scope" do
      expect do
        User.with_deleted.map(&:restore)
      end.to change { User.count }.by(1)
    end
  end
end
