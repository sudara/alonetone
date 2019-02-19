# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersHelper, type: :helper do
  it "returns request path for a missing avatar image" do
    expect(UsersHelper.no_avatar_path).to eq('/assets/default/no-pic_white.svg')
  end

  context "user with an avatar" do
    let(:user) { users(:sudara) }

    it "formats an avatar URL" do
      url = user_avatar_url(user, variant: :album)
      expect(url).to start_with('/system/pics')
      expect(url).to end_with('.jpg')
    end
  end

  context "user without an avatar" do
    let(:user) { users(:arthur) }

    it "formats a default avatar URL" do
      expect(user_avatar_url(user, variant: :album)).to eq(UsersHelper.no_avatar_path)
    end
  end
end
