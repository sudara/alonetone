require "rails_helper"

RSpec.describe AssetsController, type: :request do
  fixtures :assets, :users
  include ActiveJob::TestHelper

  before(:each) do
    DatabaseCleaner.start
  end

  append_after(:each) do
    DatabaseCleaner.clean
  end

  context "#latest" do
    it "should render the home page" do
      get '/'
      expect(response).to be_successful
    end

    it "should render the home page (white)" do
      get '/', params: { white: true }
      expect(response).to be_successful
    end
  end

  context "show" do
    it "should render without errors" do
      get user_track_path('sudara', 'song1')
      expect(response).to be_successful
    end

    it "should render without errors (white)" do
      get user_track_path('sudara', 'song1'), params: { white: true }
      expect(response).to be_successful
    end
  end

  context "#show.mp3" do
    GOOD_USER_AGENTS = [
      "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en) AppleWebKit/XX (KHTML, like Gecko) Safari/YY",
      "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8) Gecko/20060319 Firefox/2.0",
      "iTunes/x.x.x",
      "Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)",
      "msie",
      'webkit'
    ].freeze

    BAD_USER_AGENTS = [
      "Mp3Bot/0.1 (http://mp3realm.org/mp3bot/)",
      "",
      "Googlebot/2.1 (+http://www.google.com/bot.html)",
      "you're momma's so bot...",
      "Baiduspider+(+http://www.baidu.jp/spider/)",
      "baidu/Nutch-1.0 "
    ].freeze

    it 'should have a landing page' do
      get user_track_path('sudara', 'song1')
      expect(response.response_code).to eq(200)
    end

    it 'should consider an empty user agent to be a spider and not register a listen' do
      agent = ''
      expect do
        get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
      end.not_to change(Listen, :count)
    end

    it 'should consider any user agent with BOT in its string a bot and not register a listen' do
      agent = 'bot'
      expect do
        get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
      end.not_to change(Listen, :count)
    end

    it 'should accept a mp3 extension and redirect to the amazon url' do
      agent = GOOD_USER_AGENTS.first
      get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
      # expect(response).to redirect_to(assets(:valid_mp3).mp3.url) # on s3, we get a redirect
      expect(response.response_code).to eq(200) # in test mode, we get a file
    end

    GOOD_USER_AGENTS.each do |agent|
      it "should register a listen for #{agent}" do
        expect do
          get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
        end.to change { Listen.count }.by(1)
      end
    end

    BAD_USER_AGENTS.each do |agent|
      it "should not register a listen for #{agent}" do
        expect do
          get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
        end.not_to change { Listen.count }
      end
    end

    it "should NOT register more than one listen from one ip/track in short amount of time" do
      agent = GOOD_USER_AGENTS.first
      expect do
        get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
        get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
        get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
      end.to change { Listen.count }.by(1)
    end

    it "should register more than one listen from one IP when legitimate" do
      agent = GOOD_USER_AGENTS.first
      expect do
        travel_to(3.hours.ago) do
          get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
        end
        travel_to(2.hours.ago) do
          get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
        end
        travel_to(1.hour.ago) do
          get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
        end
      end.to change { Listen.count }.by(3)
    end

    it 'should record the referer' do
      agent = GOOD_USER_AGENTS.first
      referer = "https://alonetone.com/blah/blah"
      expect do
        get user_track_path('sudara', 'song1', format: :mp3),
            headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent, 'HTTP_REFERER' => referer }
      end.to change(Listen, :count)
      expect(Listen.last.source).to eq(referer)
    end

    it 'should allow the refferer to be manually overridden by params' do
      agent = GOOD_USER_AGENTS.first
      referer = "https://alonetone.com/blah/blah"
      expect do
        get user_track_path('sudara', 'song1', format: :mp3, referer: "itunes"),
            headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent, 'HTTP_REFERER' => referer }
      end.to change(Listen, :count)
      expect(Listen.last.source).to eq('itunes')
    end

    it 'should say "direct hit" when no referer' do
      agent = GOOD_USER_AGENTS.first
      expect do
        get user_track_path('sudara', 'song1', format: :mp3),
            headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
      end.to change(Listen, :count)
      expect(Listen.last.source).to eq("direct hit")
    end
  end

  context '#create' do
    before do
      post '/user_sessions', params: { user_session: { login: 'arthur', password: 'test' } }
    end

    it 'should successfully upload an mp3' do
      post '/user_sessions', params: { user_session: { login: 'arthur', password: 'test' } }

      expect do
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('assets/muppets.mp3', 'audio/mpeg')] }
      end.to change { Asset.count }.by(1)
      expect(response).to redirect_to('/arthur/tracks/mass_edit?assets%5B%5D=' + Asset.last.id.to_s)
    end

    it 'should accept an uploaded mp3 from chrome with audio/mp3 content type' do
      expect do
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('assets/muppets.mp3', 'audio/mp3')] }
      end.to change { Asset.count }.by(1)
      expect(response).to redirect_to('/arthur/tracks/mass_edit?assets%5B%5D=' + Asset.last.id.to_s)
    end

    it "should email followers and generate waveform via queue" do
      users(:sudara).add_or_remove_followee(users(:arthur).id)
      post '/arthur/tracks', params: { asset_data: [fixture_file_upload('assets/muppets.mp3', 'audio/mp3')] }
      expect(enqueued_jobs.size).to eq 2
      expect(enqueued_jobs.first[:queue]).to eq "mailers"
    end

    it 'should successfully upload 2 mp3s' do
      post '/arthur/tracks', params: { asset_data: [fixture_file_upload('assets/muppets.mp3', 'audio/mpeg'),
                                                    fixture_file_upload('assets/muppets.mp3', 'audio/mpeg')] }
      expect(response).to redirect_to('/arthur/tracks/mass_edit?assets%5B%5D=' + Asset.last(2).first.id.to_s + '&assets%5B%5D=' + Asset.last.id.to_s)
    end

    it "should successfully extract mp3s from a zip" do
      expect do
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('assets/1valid-1invalid.zip', 'application/zip')] }
      end.to change { Asset.count }.by(1)
    end

    it "should allow an mp3 upload from an url" do
      expect do
        post '/arthur/tracks', params: { asset_data: ["https://github.com/sudara/alonetone/raw/master/spec/fixtures/assets/muppets.mp3"] }
      end.to change { Asset.count }.by(1)
    end

    it "should allow a zip upload from an url" do
      expect do
        post '/arthur/tracks', params: { asset_data: ["https://github.com/sudara/alonetone/raw/master/spec/fixtures/assets/1valid-1invalid.zip"] }
      end.to change { Asset.count }.by(1)
    end
  end
end
