require 'rails_helper'

RSpec.describe Admin::MassInvitesController, type: :request do
  context 'an admin' do
    before do
      create_user_session(users(:sudara))
    end

    it 'sees an overview of all active mass invites' do
      get '/admin/mass_invites'
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
      expect(response.body).to match_css('table')
      expect(response.body).to match_css('tr', count: MassInvite.where(archived: false).count)
    end

    it 'sees an overview of all archived mass invites' do
      get '/admin/mass_invites?filter_by=archived'
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
      expect(response.body).to match_css('table')
      expect(response.body).to match_css('tr', count: MassInvite.where(archived: true).count)
    end

    it 'sees a form to create a new mass invite' do
      get '/admin/mass_invites/new'
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(response.body).to match_css('form')
    end

    it 'creates a new mass invite' do
      expect do
        post(
          '/admin/mass_invites',
          params: {
            mass_invite: {
              name: 'Christmas Surprise',
              token: 'NiFhaXEn1NCAxmKC'
            }
          }
        )
      end.to change(MassInvite, :count).by(+1)
      expect(response.status).to redirect_to(admin_mass_invites_url(filter_by: 'active'))
    end

    it 'sees validation errors when a mass invite creation fails' do
      post(
        '/admin/mass_invites',
        params: { mass_invite: { name: '', token: '' } }
      )
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(response.body).to match_css('div.field.invalid')
    end

    it 'archives a mass invite' do
      mass_invite = mass_invites(:cheese_eating_challenge)
      patch(
        "/admin/mass_invites/#{mass_invite.token}",
        params: { mass_invite: { archived: true } }
      )
      expect(response.status).to redirect_to(admin_mass_invites_url(filter_by: 'active'))
      expect(mass_invite.reload).to be_archived
    end

    it 'activates a mass invite' do
      mass_invite = mass_invites(:williams_friends)
      patch(
        "/admin/mass_invites/#{mass_invite.token}",
        params: { mass_invite: { archived: false } }
      )
      expect(response.status).to redirect_to(admin_mass_invites_url(filter_by: 'active'))
      expect(mass_invite.reload).to_not be_archived
    end
  end

  context 'a visitor' do
    it 'must login before accessing the controller' do
      get '/admin/mass_invites'
      expect(response.status).to redirect_to(login_url)
    end
  end
end
