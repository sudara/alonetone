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

  it "formats a summary for a missing user" do
    expect(user_summary(nil)).to be_blank
  end

  it "format summary for a user" do
    user = users(:jamie_kiesl)
    date = user.created_at.to_date.to_s(:long)
    profile = <<~PROFILE
      Jamiek
      Joined alonetone #{date}
      from Wilwaukee, US
    PROFILE
    expect(user_summary(user)).to eq(profile.strip)

    user = users(:will_studd)
    date = user.created_at.to_date.to_s(:long)
    profile = <<~PROFILE
      willstudd
      4 uploaded tracks
      Joined alonetone #{date}
      from AU
    PROFILE
    expect(user_summary(user)).to eq(profile.strip)

    user = users(:henri_willig)
    date = user.created_at.to_date.to_s(:long)
    profile = <<~PROFILE
      Henri Willig
      2 uploaded tracks
      Joined alonetone #{date}
      from Edam
    PROFILE
    expect(user_summary(user)).to eq(profile.strip)

    user = users(:william_shatner)
    date = user.created_at.to_date.to_s(:long)
    profile = <<~PROFILE
      Captain Bill
      Joined alonetone #{date}
    PROFILE
    expect(user_summary(user)).to eq(profile.strip)
  end

  context "no user" do
    it "formats a default avatar URL" do
      expect(user_avatar_url(nil, variant: :album)).to eq(UsersHelper.no_avatar_path)
    end

    it "formats a default dark avatar URL" do
      [:album, :large].each do |variant|
        url = dark_user_avatar_url(nil, variant: variant)
        expect(url).to start_with('default/no-pic')
        expect(url).to end_with('.png')
      end
    end
  end

  context "user with an avatar" do
    let(:user) { users(:sudara) }

    it "formats an avatar URL" do
      url = user_avatar_url(user, variant: :album)
      expect(url).to start_with('/system/pics')
      expect(url).to end_with('.jpg')
    end

    it "formats a dark avatar URL" do
      [:album, :large].each do |variant|
        url = dark_user_avatar_url(user, variant: variant)
        expect(url).to start_with('/system/pics')
        expect(url).to end_with('.jpg')
      end
    end
  end

  context "user without an avatar" do
    let(:user) { users(:arthur) }

    it "formats a default avatar URL" do
      expect(user_avatar_url(user, variant: :album)).to eq(UsersHelper.no_avatar_path)
    end

    it "formats a default dark avatar URL" do
      [:album, :large].each do |variant|
        expect(
          dark_user_avatar_url(user, variant: variant)
        ).to eq(UsersHelper.no_dark_avatar_path(variant: variant))
      end
    end

    it "actually has the default avatar on disk" do
      expect(Rails.application.assets.find_asset(UsersHelper.no_avatar_path)).to_not be_nil
    end

    it "actually has all default dark avatars on disk" do
      ImageVariant::VARIANTS.keys.each do |variant|
        path = UsersHelper.no_dark_avatar_path(variant: variant)
        expect(Rails.application.assets.find_asset(path)).to_not be_nil
      end
    end
  end
end
