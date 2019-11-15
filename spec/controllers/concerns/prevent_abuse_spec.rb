# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreventAbuse do
  let(:base) do
    Struct.new(:request) { include PreventAbuse }
  end

  it "allows UC (s9) as a browser" do
    request = OpenStruct.new(user_agent: "Mozilla/5.0 (Linux; U; Android 6.0.1; zh-CN; F5121 Build/34.0.A.1.247) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/40.0.2214.89 UCBrowser/11.5.1.944 Mobile Safari/537.36")
    controller = base.new(request)
    expect(controller.browser?).to be_truthy
  end

  it "does not allow MJ12bot as a browser" do
    request = OpenStruct.new(user_agent: "Mozilla/5.0 (compatible; MJ12bot/v1.4.8; http://mj12bot.com/)")
    controller = base.new(request)
    expect(controller.browser?).to be_falsey
  end
end
