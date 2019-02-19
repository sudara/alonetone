# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersHelper, type: :helper do
  it "returns request path for a missing avatar image" do
    expect(UsersHelper.no_avatar_path).to eq('default/no-pic_white.svg')
  end

  it "formats location for a user without profile" do
    expect(user_location(nil)).to be_blank
  end

  it "formats location for a user with a profile" do
    expect(user_location(profiles(:jamie_kiesl))).to eq('from Wilwaukee, US')
    expect(user_location(profiles(:will_studd))).to eq('from AU')
    expect(user_location(profiles(:henri_willig))).to eq('from Edam')
    expect(user_location(profiles(:william_shatner))).to eq('')
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
