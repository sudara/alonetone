require "rails_helper"

RSpec.describe UserSessionsController, type: :request do
  it "should fail to login with wrong password" do
    post '/user_sessions', params: { user_session: { login: 'arthur', password: 'incorrect' } }
    expect(session[:user_credentials]).to_not be_present
    expect(response).to render_template('user_sessions/new')
  end

  it "should successfully login with alonetone login" do
    post '/user_sessions', params: { user_session: { login: 'arthur', password: 'test' } }
    expect(session[:user_credentials]).to be_present
  end
end
