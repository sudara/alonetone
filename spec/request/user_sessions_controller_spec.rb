require "rails_helper"

RSpec.describe UserSessionsController, type: :request do
  it "should fail to login with wrong password" do
    post '/user_sessions', params: { user_session: { login: 'arthur', password: 'incorrect' } }
    expect(session[:user_credentials]).to_not be_present
    expect(response.body).to include("Don't be shy, come on in!")
  end

  it "should successfully login with alonetone login" do
    post '/user_sessions', params: { user_session: { login: 'arthur', password: 'test' } }
    expect(session[:user_credentials]).to eq(users(:arthur).persistence_token)
  end

  it "should successfully login with email" do
    post '/user_sessions', params: { user_session: { login: 'arthur@example.com', password: 'test' } }

    expect(session[:user_credentials]).to eq(users(:arthur).persistence_token)
  end

  it "should redirect to user's home after login" do
    post '/user_sessions', params: { user_session: { login: 'arthur', password: 'test' } }

    expect(response).to redirect_to('http://www.example.com/arthur')
  end

  it "redirects with See Other so Turbo follows the login" do
    post '/user_sessions', params: { user_session: { login: 'arthur', password: 'test' } }

    expect(response).to have_http_status(:see_other)
  end

  it "re-renders with Unprocessable Content on a failed login" do
    post '/user_sessions', params: { user_session: { login: 'arthur', password: 'bad password' } }

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "should redirect to last page viewed after login" do
    get '/sudara'

    post '/user_sessions', params: { user_session: { login: 'arthur', password: 'test' } }

    expect(response).to redirect_to('http://www.example.com/sudara')
  end

  it "should not login a user with a bad password" do
    post '/user_sessions', params: { user_session: { login: 'arthur', password: 'bad password' } }

    expect(session[:user_credentials]).not_to be_present
  end

  it "should log out when requested" do
    create_user_session(users(:arthur))

    get '/logout'

    expect(response).to redirect_to('http://www.example.com/login')
  end

  it "should delete session cookie on logout" do
    create_user_session(users(:arthur))

    get '/logout'

    expect(session[:user_credentials]).not_to be_present
  end

  it "should update IP and last_request_at" do
    user = users(:arthur)

    travel_to(1.hour.ago) do
      post(
        '/user_sessions',
        params: { user_session: { login: user.login, password: 'test' } },
        headers: { 'REMOTE_ADDR' => '10.1.1.1' }
      )
    end

    expect(session[:user_credentials]).to eq(user.reload.persistence_token)
    expect(user.current_login_ip).to eq('10.1.1.1')
    expect(user.last_request_at).to be_within(1.minute).of(1.hour.ago)
  end
end
