require "rails_helper"

RSpec.describe MassInvitesUsersController, type: :request do
  context 'active mass invite' do
    let(:mass_invite) { mass_invites(:november_invite) }

    it 'shows a form to create a new user' do
      get "/mass_invites/#{mass_invite.token}/users/new"
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(response.body).to match_css('form')
    end

    it 'creates a new user' do
      akismet_stub_response_ham
      expect do
        expect do
          post(
            "/mass_invites/#{mass_invite.token}/users",
            params: {
              user: {
                email: 'jeremy@example.com',
                login: 'Jeremy',
                password: 'secret123-',
                password_confirmation: 'secret123-'
              }
            },
            headers: {
              'x-forwarded-for' => '62.251.41.177',
              'user-agent' => 'webkit'
            }
          )
        end.to change(User, :count).by(+1)
      end.to change { mass_invite.reload.users_count }.by(+1)
      expect(response).to redirect_to(login_url(already_joined: true))
    end

    it 'shows validation errors when creation failed' do
      akismet_stub_response_ham
      expect do
        post(
          "/mass_invites/#{mass_invite.token}/users",
          params: {
            user: {
              email: '',
              login: '',
              password: '',
              password_confirmation: ''
            }
          },
          headers: {
            'x-forwarded-for' => '62.251.41.177',
            'user-agent' => 'webkit'
          }
        )
      end.to_not change(User, :count)
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(response.body).to match_css('div.inline_form_error')
    end

    it 'redirects to the form when someone enters the URL from a failed creation request' do
      get "/mass_invites/#{mass_invite.token}/users"
      expect(response).to redirect_to(new_mass_invite_users_url(mass_invite))
    end
  end

  context 'archived mass invite' do
    let(:mass_invite) { mass_invites(:williams_friends) }

    it 'shows a message that the mass invite is closed' do
      get "/mass_invites/#{mass_invite.token}/users/new"
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:archived)
      expect(response.body).to match_css('h1')
    end
  end
end
