require "rails_helper"

RSpec.describe AssetsController, type: :request do
  before do
    akismet_stub_response_ham
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

  context '#new' do
    before do
      create_user_session(users(:brand_new_user))
    end

    it 'should not allow new users w/ >= 25 tracks to upload' do
      get '/upload'
      expect(response).to be_successful
      expect(response.body).to include('To prevent abuse, new users are limited to 25 uploads in their first day. Come back tomorrow!')
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
      expect {
        get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
      }.not_to change(Listen, :count)
    end

    it 'should consider any user agent with BOT in its string a bot and not register a listen' do
      agent = 'bot'
      expect {
        get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
       }.not_to change(Listen, :count)
    end

    it 'should accept a mp3 extension and redirect to the amazon url' do
      agent = GOOD_USER_AGENTS.first
      get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
      # expect(response).to redirect_to(assets(:valid_mp3).mp3.url) # on s3, we get a redirect
      expect(response.response_code).to eq(200) # in test mode, we get a file
    end

    GOOD_USER_AGENTS.each do |agent|
      it "should register a listen for #{agent}" do
        expect {
          get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
        }.to change { Listen.count }.by(1)
      end
    end

    BAD_USER_AGENTS.each do |agent|
      it "should not register a listen for #{agent}" do
        expect {
          get user_track_path('sudara', 'song1', format: :mp3), headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
          }.not_to change { Listen.count }
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
      expect {
        get user_track_path('sudara', 'song1', format: :mp3),
        headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent, 'HTTP_REFERER' => referer }
       }.to change(Listen, :count)
      expect(Listen.last.source).to eq(referer)
    end

    it 'should allow the refferer to be manually overridden by params' do
      agent = GOOD_USER_AGENTS.first
      referer = "https://alonetone.com/blah/blah"
      expect {
        get user_track_path('sudara', 'song1', format: :mp3, referer: "itunes"),
        headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent, 'HTTP_REFERER' => referer }
      }.to change(Listen, :count)
      expect(Listen.last.source).to eq('itunes')
    end

    it 'should say "direct hit" when no referer' do
      agent = GOOD_USER_AGENTS.first
      expect {
        get user_track_path('sudara', 'song1', format: :mp3),
        headers: { 'HTTP_ACCEPT' => "audio/mpeg", 'HTTP_USER_AGENT' => agent }
      }.to change(Listen, :count)
      expect(Listen.last.source).to eq("direct hit")
    end
  end

  context '#create' do
    before do
      create_user_session(users(:brand_new_user))
    end

    it 'should prevent uploads from new users with >= 25 tracks' do
      post '/brandnewuser/tracks', params: { asset_data: [fixture_file_upload('files/muppets.mp3', 'audio/mpeg')] }
      follow_redirect!
      expect(response.body).to include('To prevent abuse, new users are limited to 25 uploads in their first day. Come back tomorrow!')
    end
  end

  context '#create' do
    let(:mp3_asset_url) do
      'https://example.com/muppets.mp3'
    end
    let(:zip_asset_url) do
      'https://example.com/1valid-1invalid.zip'
    end
    let(:user) { users(:arthur) }

    before do
      create_user_session(user)

      stub_request(:get, mp3_asset_url).and_return(
        body: file_fixture_pathname('muppets.mp3').open(
          encoding: 'binary'
        ),
        headers: { 'Content-Type' => 'audio/mpeg' }
      )
      stub_request(:get, zip_asset_url).and_return(
        body: file_fixture_pathname('1valid-1invalid.zip').open(
          encoding: 'binary'
        ),
        headers: { 'Content-Type' => 'application/zip' }
      )
    end

    it 'should successfully upload an mp3' do
      expect do
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('files/muppets.mp3', 'audio/mpeg')] }
      end.to change { Asset.count }.by(1)

      expect(response).to redirect_to('/arthur/tracks/mass_edit?assets%5B%5D=' + Asset.last.id.to_s)
    end

    it 'should accept an uploaded mp3 from chrome with audio/mp3 content type' do
      expect {
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('files/muppets.mp3', 'audio/mp3')] }
      }.to change { Asset.count }.by(1)
      expect(response).to redirect_to('/arthur/tracks/mass_edit?assets%5B%5D=' + Asset.last.id.to_s)
    end

    it "should email followers and generate waveform via queue" do
      users(:sudara).add_or_remove_followee(users(:arthur).id)
      post '/arthur/tracks', params: { asset_data: [fixture_file_upload('files/muppets.mp3', 'audio/mp3')] }
      expect(enqueued_jobs.size).to eq 1
      expect(enqueued_jobs.first[:queue]).to eq "mailers"
    end

    it 'should successfully upload 2 mp3s' do
      post '/arthur/tracks', params: { asset_data: [fixture_file_upload('files/muppets.mp3', 'audio/mpeg'),
                                                                      fixture_file_upload('files/muppets.mp3', 'audio/mpeg')] }
      expect(response).to redirect_to('/arthur/tracks/mass_edit?assets%5B%5D=' + Asset.last(2).first.id.to_s + '&assets%5B%5D=' + Asset.last.id.to_s)
    end

    it 'creates an album from a ZIP' do
      expect do
        expect do
          post '/arthur/tracks', params: {
            asset_data: [fixture_file_upload('files/Le Duc Vacherin.zip', 'application/zip')]
          }
        end.to change { user.assets.count }.by(+3)
      end.to change { user.playlists.count }.by(+1)
    end

    it "should successfully extract mp3s from a zip" do
       expect {
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('files/1valid-1invalid.zip', 'application/zip')] }
      }.to change { Asset.count }.by(1)
    end

    it "should allow an mp3 upload from an url" do
      expect {
        post '/arthur/tracks', params: { asset_data: [mp3_asset_url] }
      }.to change { Asset.count }.by(1)
    end

    it "should allow a zip upload from tan url" do
      expect {
        post '/arthur/tracks', params: { asset_data: [zip_asset_url] }
      }.to change { Asset.count }.by(1)
    end
  end
end
