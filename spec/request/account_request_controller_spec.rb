require "rails_helper"

RSpec.describe AccountRequestsController, type: :request do
  context 'active mass invite' do
    it 'shows a form to create a new user' do
      get "/get_an_account"
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(response.body).to match_css('form')
    end

    it 'creates a new account request' do
      akismet_stub_response_ham
      expect do
        post(
          "/get_an_account",
          params: {
            account_request: {
              email: 'jeremy@example.com',
              login: 'Jeremy',
              entity_type: 'musician',
              details: "I had something to say but I can't quite remember. Something something music."
            }
          }
        )
      end.to change(AccountRequest, :count).by(+1)
      expect(response).to render_template('thank_you')
      expect(response).to have_http_status(303)
      expect(AccountRequest.last).to be_waiting
    end

    it 'auto-denies spam account requests' do
      akismet_stub_response_spam
      expect do
        post(
          "/get_an_account",
          params: {
            account_request: {
              email: 'spammer@example.com',
              login: 'SpamBot',
              entity_type: 'musician',
              details: "Buy cheap stuff at my website! Check out these deals on everything you need!"
            }
          }
        )
      end.to change(AccountRequest, :count).by(+1)
      expect(response).to render_template('thank_you')
      expect(response).to have_http_status(303)
      expect(AccountRequest.last).to be_denied
    end

    it 'still saves the request when akismet is unreachable' do
      stub_request(:post, %r{rest.akismet.com/1.1/comment-check}).to_timeout
      expect do
        post(
          "/get_an_account",
          params: {
            account_request: {
              email: 'timeout@example.com',
              login: 'TimeoutUser',
              entity_type: 'musician',
              details: "I had something to say but I can't quite remember. Something something music."
            }
          }
        )
      end.to change(AccountRequest, :count).by(+1)
      expect(response).to render_template('thank_you')
      expect(AccountRequest.last).to be_waiting
    end

    it 'shows validation errors when creation failed' do
      expect do
        post(
          "/get_an_account",
          params: {
            account_request: {
              email: '',
              login: '',
              password: '',
              password_confirmation: ''
            }
          }
        )
      end.to_not change(User, :count)
      expect(response).to have_http_status(422)
      expect(response).to render_template(:new)
      expect(response.body).to match_css('div.inline_form_error')
    end
  end
end
