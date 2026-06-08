require "rails_helper"

RSpec.describe ReservedWord, type: :model do
  describe("validation") do
    it "rejects a name that is not a valid regular expression" do
      word = ReservedWord.new(name: "[unclosed")
      expect(word).not_to be_valid
      expect(word.errors.details[:name]).to include(error: :invalid_regexp)
    end
  end

  describe("#contains") do
    it "returns false for a name that is not a valid regular expression" do
      expect(ReservedWord.new(name: "[unclosed").contains("anything")).to be(false)
    end

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
