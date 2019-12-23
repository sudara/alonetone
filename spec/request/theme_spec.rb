require "rails_helper"

RSpec.describe "Theme", type: :request do
  it "should be light for guests" do
    get "/"
    expect(session[:theme]).to eql('light')
  end

  it "should be light for a user if they have nothing configured" do
    create_user_session(users(:arthur))
    get '/'
    expect(session[:theme]).to eql('light')
  end

  it "should be dark for a user if they have dark configured" do
    create_user_session(users(:sudara))
    get '/'
    expect(session[:theme]).to eql('dark')
  end

  it "should persist toggling themes from light to dark" do
    create_user_session(users(:arthur))
    get "/"
    expect(session[:theme]).to eql('light')
    put '/toggle_theme.js'
    get '/users'
    expect(session[:theme]).to eql('dark')
  end

  it "should persist toggling themes from dark to light" do
    create_user_session(users(:sudara))
    get "/"
    expect(session[:theme]).to eql('dark')
    put '/toggle_theme.js'
    get '/users'
    expect(session[:theme]).to eql('light')
  end

  context "with conditional GET caching" do
     before do
      create_user_session(users(:sudara))
      get '/'
      expect(response.code).to eql("200")
      expect(response.headers['ETag']).to be_present
      expect(response.headers['Last-Modified']).to be_present
      @etag = response.headers['ETag']
      @last_modified = response.headers['Last-Modified']
    end

    it "should return 304 not modified when theme doesn't change" do
      get "/", headers: { 'HTTP_IF_NONE_MATCH': @etag, 'HTTP_IF_MODIFIED_SINCE': @last_modified }
      expect(session[:theme]).to eql('dark')
      expect(response).to have_http_status(304)
    end

    it "should not return 304 when theme changes because the etag will change" do
      expect(session[:theme]).to eql('dark')
      put '/toggle_theme.js'
      get "/", headers: { 'HTTP_IF_NONE_MATCH': @etag, 'HTTP_IF_MODIFIED_SINCE': @last_modified }
      expect(session[:theme]).to eql('light')
      expect(response.headers['ETag']).to_not eql(@etag)
      expect(response).to have_http_status(200)
    end
  end
end
