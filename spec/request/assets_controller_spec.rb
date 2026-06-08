require "rails_helper"

RSpec.describe AssetsController, type: :request do
  let(:fastly_base_url) { 'https://fastly.example.com' }

  before do
    akismet_stub_response_ham
  end

  around do |example|
    # Switch back to filesystem storage for this particular controller because
    # it needs to store and retrieve files. We also use Fastly
    # locations so we don't need a file on disk to generate a URL.
    with_storage_service(:filesystem) do
      with_alonetone_configuration(fastly_base_url: fastly_base_url) do
        example.call
      end
    end
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

    it "wires track rows to the persistent player" do
      get '/'
      expect(response.body).to include('data-controller="tracklist"')
      expect(response.body).to include('data-tracklist-target="track"')
    end

    # testing popular part of latest page
    # since it's easier to control than .latest
    # that's ordered by id
    it "should not display spammed assets" do
      assets = Asset.with_preloads.published.latest.limit(2)
      get '/', params: { white: true }

      expect(response.body).to include(assets.first.title)
      expect(response.body).to include(assets.last.title)
      # spam one and leave the other
      akismet_stub_submit_spam
      AssetCommand.new(assets.first).spam_and_soft_delete_with_relations
      get '/', params: { white: true }
      expect(response.body).not_to include(assets.first.title)
      expect(response.body).to include(assets.last.title)
    end

    it 'caps a single user to 2 tracks in the latest list' do
      spammer = users(:arthur)
      6.times do |i|
        asset = spammer.assets.build(title: "spam-track-#{i}", permalink: "spam-track-#{i}", private: false)
        asset.save(validate: false)
        asset.update_column(:created_at, Time.current + i.seconds)
      end

      get '/', params: { white: true }

      latest_area = Nokogiri::HTML(response.body).at_css('#home_latest_area').to_html
      expect(latest_area).to include('spam-track-5')
      expect(latest_area).to include('spam-track-4')
      expect(latest_area).not_to include('spam-track-3')
    end

    it 'caps a single user to 2 playlists in the recent playlists list' do
      spammer = users(:arthur)
      6.times do |i|
        playlist = spammer.playlists.build(title: "spam-playlist-#{i}", published: true, is_mix: true)
        playlist.save(validate: false)
        playlist.update_columns(published_at: Time.current + i.seconds)
      end

      get '/', params: { white: true }

      playlists_area = Nokogiri::HTML(response.body).at_css('#home_playlists_area').to_html
      expect(playlists_area).to include('spam-playlist-5')
      expect(playlists_area).to include('spam-playlist-4')
      expect(playlists_area).not_to include('spam-playlist-3')
    end

    # take the latest published (where(private: false)) asset to make sure it
    # should have been displayed on the page
    it 'should not display a deleted asset whose user was also deleted' do
      asset = Asset.with_preloads.published.latest.first
      get '/', params: { white: true }
      expect(response.body).to include(asset.title)

      UserCommand.new(asset.user).soft_delete_with_relations
      asset.reload
      get '/', params: { white: true }
      expect(asset.soft_deleted?).to eq(true)
      expect(response.body).not_to include(asset.title)
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

    it 'disables the form for new users with >= 25 tracks' do
      get '/upload'
      expect(response.body).to include('disabled="disabled"')
    end
  end

  context "show" do
    before do
      allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(false)
    end

    it "should render without errors" do
      get user_track_path('sudara', 'song1')
      expect(response).to be_successful
    end

    it "should render without errors (white)" do
      get user_track_path('sudara', 'song1'), params: { white: true }
      expect(response).to be_successful
    end

    it 'shows an assets without an attachment' do
      get user_track_path('henri_willig', 'this-track-has-no-mp3')
      expect(response).to be_successful
    end

    it "enqueues a CreateAudioFeature job if an asset does not have a waveform" do
      asset = assets(:valid_mp3_2)
      asset.audio_feature.delete

      expect {
        get user_track_path(asset.user.login, asset.id)
      }.to have_enqueued_job(CreateAudioFeatureJob)
    end

    it "does not enqueue a CreateAudioFeature job if a waveform is present" do
      asset = assets(:valid_mp3)

      expect {
        get user_track_path(asset.user.login, asset.id)
      }.not_to have_enqueued_job(CreateAudioFeatureJob)
    end

    it "does not enqueue a CreateAudioFeature job for bots" do
      allow_any_instance_of(PreventAbuse).to receive(:is_a_bot?).and_return(true)
      asset = assets(:valid_mp3)

      expect {
        get user_track_path(asset.user.login, asset.id)
      }.not_to have_enqueued_job(CreateAudioFeatureJob)
    end

    context "private comments" do
      let(:asset) { assets(:valid_arthur_mp3) }
      let(:private_comment) { comments(:private_comment_on_asset_by_guest) }

      it "shows private comments to the track owner" do
        create_user_session(users(:arthur))
        get user_track_path(asset.user.login, asset.id)
        expect(response.body).to include(private_comment.body)
      end

      it "shows private comments to admins" do
        create_user_session(users(:sudara))
        get user_track_path(asset.user.login, asset.id)
        expect(response.body).to include(private_comment.body)
      end

      it "shows private comments to moderators" do
        create_user_session(users(:sandbags))
        get user_track_path(asset.user.login, asset.id)
        expect(response.body).to include(private_comment.body)
      end

      it "hides private comments from guests" do
        get user_track_path(asset.user.login, asset.id)
        expect(response.body).not_to include(private_comment.body)
      end

      it "hides private comments from other users" do
        create_user_session(users(:henri_willig))
        get user_track_path(asset.user.login, asset.id)
        expect(response.body).not_to include(private_comment.body)
      end
    end
  end

  context "index" do
    it "renders the track index" do
      create_user_session(users(:sudara))
      get user_tracks_path('sudara')

      expect(response).to be_successful
      expect(response.media_type).to eq('text/html')
    end

    it "displays a user's track if it is hot" do
      create_user_session(users(:sudara))
      assets(:valid_mp3).update(hotness: 2)

      get user_tracks_path('sudara')

      expect(response.body).to include('Hot Tracks this week')
      expect(response.body).to include('Very good song')
    end

    it "displays a custom message if a user has no tracks yet" do
      get user_tracks_path('joeblow')
      expect(response.body).to include("Looks like joeblow hasn't uploaded anything yet!")
    end
  end

  context "#waveform" do
    let(:default_points) { WaveformToSvg.new(nil).points }

    it "returns the track's real waveform points as json without requiring login" do
      get waveform_user_track_path('sudara', 'song1')
      expect(response).to be_successful
      expect(response.media_type).to eq('application/json')
      points = JSON.parse(response.body)['points']
      expect(points).to be_present
      expect(points).not_to eq(default_points)
    end

    it "falls back to the placeholder waveform when none has been generated yet" do
      get waveform_user_track_path('henri_willig', 'manufacturer-of-the-finest-cheese')
      expect(response).to be_successful
      expect(JSON.parse(response.body)['points']).to eq(default_points)
    end

    it "404s for a track that does not exist" do
      get waveform_user_track_path('sudara', 'no-such-track')
      expect(response).to have_http_status(:not_found)
    end
  end

  context "#radio" do
    %w[those_you_follow songs_you_have_not_heard mangoz_shuffle].each do |source|
      it "404s when a guest requests #{source}" do
        get radio_source_home_path(source)
        expect(response).to have_http_status(:not_found)
      end
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
      post '/brandnewuser/tracks', params: { asset_data: [fixture_file_upload('muppets.mp3', 'audio/mpeg')] }
      follow_redirect!
      expect(response.body).to include('To prevent abuse, new users are limited to 25 uploads in their first day. Come back tomorrow!')
    end
  end

  context "#mass_edit" do
    it "allows a user to edit one track" do
      asset = assets(:valid_arthur_mp3)
      create_user_session(users(:arthur))

      get mass_edit_user_tracks_path('arthur'), params: { assets: [asset.id] }

      expect(response).to be_successful
      expect(response.body).to include(asset.name)
    end

    it "allows a user to edit two tracks at once" do
      user = users(:sudara)
      two_assets = [user.assets.first, user.assets.last]
      create_user_session(user)

      get mass_edit_user_tracks_path(user.login), params: { assets: two_assets.map(&:id) }

      expect(response).to be_successful
      expect(response.body).to include(two_assets.first.name)
      expect(response.body).to include(two_assets.last.name)
    end

    it "does not allow users to edit other people's tracks" do
      other_asset = assets(:valid_mp3)
      own_asset = assets(:valid_arthur_mp3)
      create_user_session(users(:arthur))

      get mass_edit_user_tracks_path('arthur'), params: { assets: [other_asset.id] }

      expect(response).to be_successful
      expect(response.body).not_to include(other_asset.name)
      expect(response.body).to include(own_asset.name)
    end

    it "does not error without selected assets" do
      create_user_session(users(:arthur))

      get mass_edit_user_tracks_path('arthur')

      expect(response).to be_successful
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
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('muppets.mp3', 'audio/mpeg')] }
      end.to change { Asset.count }.by(1)

      expect(response).to redirect_to('/arthur/tracks/old-muppet-men-booing/edit')
    end

    it 'uses the filename as the asset title when the title ID3 tag is empty' do
      post '/arthur/tracks', params: { asset_data: [fixture_file_upload('emptytags.mp3', 'audio/mpeg')] }
      expect(response).to redirect_to('/arthur/tracks/emptytags/edit')
    end

    it 'should accept an uploaded mp3 from chrome with audio/mp3 content type' do
      expect {
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('muppets.mp3', 'audio/mp3')] }
      }.to change { Asset.count }.by(1)
      expect(response).to redirect_to('/arthur/tracks/old-muppet-men-booing/edit')
    end

    # Waveform job is enqueued in an after_create callback
    it "should generate waveform via queue" do
      expect {
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('muppets.mp3', 'audio/mp3')] }
      }.to have_enqueued_job(WaveformExtractJob)
    end

    it "should send an email to followers" do
      # add two followers
      # to test that ActionMailer sends multiple emails
      users(:sudara).add_or_remove_followee(users(:arthur).id)
      users(:aaron).add_or_remove_followee(users(:arthur).id)
      expect {
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('muppets.mp3', 'audio/mp3')] }
      }.to have_enqueued_job(AssetNotificationJob).exactly(:twice).and have_enqueued_job(WaveformExtractJob)
    end

    it 'should successfully upload 2 mp3s' do
      post '/arthur/tracks', params: {
        asset_data: [
          fixture_file_upload('muppets.mp3', 'audio/mpeg'),
          fixture_file_upload('muppets.mp3', 'audio/mpeg')
        ]
      }
      expect(response).to redirect_to("/arthur/tracks/mass_edit?assets%5B%5D=#{Asset.last(2).first.id}&assets%5B%5D=#{Asset.last.id}")
    end

    it 'creates an album from a ZIP' do
      expect do
        expect do
          post '/arthur/tracks', params: {
            asset_data: [fixture_file_upload('Le Duc Vacherin.zip', 'application/zip')]
          }
        end.to change { user.assets.count }.by(+3)
      end.to change { user.playlists.count }.by(+1)
    end

    it "should successfully extract mp3s from a zip" do
       expect {
        post '/arthur/tracks', params: { asset_data: [fixture_file_upload('1valid-1invalid.zip', 'application/zip')] }
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

  context "a musician" do
    let(:user) { users(:will_studd) }
    let(:asset) { user.assets.first }

    before do
      create_user_session(user)
    end

    it "sees a form to update an asset" do
      get "/#{user.login}/tracks/#{asset.to_param}/edit"
      expect(response).to be_successful
    end

    it "wires the edit page big player to the persistent player" do
      get "/#{user.login}/tracks/#{asset.to_param}/edit"
      expect(response.body).to include('data-controller="tracklist"')
      expect(response.body).to include('data-tracklist-target="track"')
    end

    it "updates the audio file for an asset" do
      akismet_stub_response_ham
      patch(
        "/#{user.login}/tracks/#{asset.to_param}",
        params: {
          asset: { audio_file: fixture_file_upload('muppets.mp3', 'audio/mpeg') }
        }
      )
      expect(response).to redirect_to('/willstudd/tracks/magnificent-lacaune')
    end

    it "does not change the listen count when updating the audio file" do
      listens_count = asset.listens_count

      patch(
        "/#{user.login}/tracks/#{asset.to_param}",
        params: {
          asset: { audio_file: fixture_file_upload('muppets.mp3', 'audio/mpeg') }
        }
      )

      expect(asset.reload.listens_count).to eq(listens_count)
    end

    it "renders an error when the asset update fails" do
      allow_any_instance_of(Asset).to receive(:update).and_return(false)

      patch(
        "/#{user.login}/tracks/#{asset.to_param}",
        params: {
          asset: { audio_file: fixture_file_upload('muppets.mp3', 'audio/mpeg') }
        }
      )

      expect(response.body).to include('There was an issue with updating that track')
    end

    it "still allows a new audio file when Akismet marks the request as spam" do
      akismet_stub_response_spam

      patch(
        "/#{user.login}/tracks/#{asset.to_param}",
        params: {
          asset: { audio_file: fixture_file_upload('tag1.mp3', 'audio/mpeg') }
        }
      )

      expect(asset.reload.mp3_file_name).to eq('tag1.mp3')
    end

    it "sets a Saved! flash on a successful non-turbo-frame update" do
      patch(
        "/#{user.login}/tracks/#{asset.to_param}",
        params: { asset: { title: 'Renamed' } }
      )
      expect(response).to have_http_status(:redirect)
      expect(flash[:ok]).to eq('Saved!')
    end

    it "does not set the flash for a turbo-frame update" do
      patch(
        "/#{user.login}/tracks/#{asset.to_param}",
        params: { asset: { title: 'Renamed' } },
        headers: { 'Turbo-Frame' => "asset_#{asset.id}" }
      )
      expect(response).to have_http_status(:ok)
      expect(flash[:ok]).to be_nil
    end

    it "can delete their track" do
      delete "/#{user.login}/tracks/#{asset.to_param}"
      expect(response).to redirect_to(user_tracks_path(user))
      expect(response.code).to eql("303")
    end
  end

  context "#destroy" do
    let(:asset) { assets(:asset_with_relations_for_soft_delete) }

    before do
      create_user_session(users(:sudara))
    end

    it "soft deletes the asset and its dependent visible relations" do
      comments_count = asset.comments.count
      listens_count = asset.listens.count
      tracks_count = asset.tracks.count
      audio_feature_count = AudioFeature.count
      playlist = asset.tracks.first.playlist
      playlist_tracks_count = playlist.tracks_count
      user = asset.user
      user_listens_count = user.listens_count

      expect(comments_count).to be > 0
      expect(listens_count).to be > 0
      expect(tracks_count).to be > 0
      expect(asset.audio_feature).to be_present
      expect(playlist_tracks_count).to be >= 1
      expect(user_listens_count).to be > 0

      expect {
        expect {
          expect {
            expect {
              delete user_track_path(asset.user.login, asset.id)
            }.to change(Asset, :count).by(-1)
          }.to change(Comment, :count).by(-comments_count)
        }.to change(Track, :count).by(-tracks_count)
      }.to change(Listen, :count).by(-listens_count)

      expect(AudioFeature.count).to eq(audio_feature_count)
      expect(playlist.reload.tracks.count).to eq(playlist_tracks_count - 1)
      expect(playlist.tracks_count).to eq(playlist_tracks_count - 1)
      expect(user.reload.listens_count).to eq(user_listens_count)
    end
  end
end
