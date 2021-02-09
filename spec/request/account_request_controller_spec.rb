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
      expect(response).to redirect_to(assigns(:account_request))
      expect(response).to have_http_status(303)
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
          },
        )
      end.to_not change(User, :count)
      expect(response).to have_http_status(422)
      expect(response).to render_template(:new)
      expect(response.body).to match_css('div.inline_form_error')
    end
  end
end
