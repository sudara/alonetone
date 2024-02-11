require "rails_helper"

RSpec.describe ReservedWord, type: :model do
  describe("#contains") do
    it "performs exact matches" do
      expect(reserved_words(:petaq).contains("petaQ")).to be_truthy
    end

    it "performs case-insensitive matches" do
      expect(reserved_words(:petaq).contains("petaq")).to be_truthy
    end

    it "performs regular-expression matches" do
      expect(reserved_words(:trader).contains("Andorian Trader")).to be_truthy
      expect(reserved_words(:trader).contains("Andorian Traders")).to be_falsey
    end
  end
end