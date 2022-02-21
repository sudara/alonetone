require "rails_helper"

RSpec.describe DiscourseSsoController, type: :request do
  it 'requires user to be logged in' do
    get '/login/sso'
    expect(response).to redirect_to('/login')
  end

  it 'expects an sso and sig query param' do
    create_user_session(users(:brand_new_user))
    expect { get '/login/sso' }.to raise_exception
  end

  it 'expects a valid sso and sig query param' do
    create_user_session(users(:brand_new_user))
    expect { get '/login/sso?sso=1234&sig=5678' }.to raise_exception
  end

  it 'expects a valid sso and sig query param' do
    create_user_session(users(:brand_new_user))
    base64sso = Base64.encode64("me=you")
    get "/login/sso?sso=#{base64sso}&sig=47390cb4722ad961891c12cbf74c1d32ca46831825fe9bf578487384e9a3397e"
    expect(response).to redirect_to("https://someforum.test?sso=YWRtaW49ZmFsc2UmbW9kZXJhdG9yPWZhbHNlJmF2YXRhcl91cmw9JmVtYWlsPWJyYW5kbmV3dXNlciU0MGV4YW1wbGUuY29tJmV4dGVybmFsX2lkPTEwNDUzNjEwMzEmbmFtZT1icmFuZG5ld3VzZXImdXNlcm5hbWU9YnJhbmRuZXd1c2Vy&sig=461c2e4ef8bb73a935f7a02266de5b58810d2640d778ecf2c99f6551fba815b4")
  end
end
