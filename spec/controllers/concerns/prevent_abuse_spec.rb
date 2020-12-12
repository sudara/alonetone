# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreventAbuse do
  let(:base) do
    Struct.new(:request) { include PreventAbuse }
  end

  it "allows requests which appear to not be from a bot" do
    request = OpenStruct.new(
      ip: '62.251.41.177',
      user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36"
    )
    controller = base.new(request)
    expect(controller.is_a_bot?).to be_falsey
  end

  it "disallows bad IP address ranges" do
    request = OpenStruct.new(ip: '121.14.1.1')
    controller = base.new(request)
    expect(controller.is_from_a_bad_ip?).to be_truthy
  end

  it "allows good IP address ranges" do
    request = OpenStruct.new(ip: '62.251.41.177')
    controller = base.new(request)
    expect(controller.is_from_a_bad_ip?).to be_falsey
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

  it "sees Yandex as a bot" do
    request = OpenStruct.new(ip: '127.0.0.1', user_agent: "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106")
    controller = base.new(request)
    expect(controller.is_a_bot?).to be_truthy
  end

  it "sees Baidu as a bot" do
    request = OpenStruct.new(ip: '127.0.0.1', user_agent: "Mozilla/5.0 (compatible; Baiduspider-render/2.0; +http://www.baidu.com/search/spider.html)")
    controller = base.new(request)
    expect(controller.is_a_bot?).to be_truthy
  end
end
