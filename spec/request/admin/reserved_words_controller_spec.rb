require 'rails_helper'

RSpec.describe Admin::ReservedWordsController, type: :request do
  context 'an admin' do
    before do
      create_user_session(users(:sudara))
    end

    it 'sees an overview of all reserved words' do
      get '/admin/reserved_words'
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
      expect(response.body).to match_css('table')
      expect(response.body).to match_css('tr', count: MassInvite.count)
    end

    it 'sees a form to create a new reserved word' do
      get '/admin/reserved_words/new'
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(response.body).to match_css('form')
    end

    describe '#delete' do
      it "should delete a user" do
        expect {
          put delete_admin_reserved_word_path(reserved_words(:petaq))
        }.to change(ReservedWord, :count).by(-1)
      end

      it "should redirect admin to root_path" do
        put delete_admin_reserved_word_path(reserved_words(:petaq))
        expect(response).to redirect_to(admin_reserved_words_path)
      end
    end
  end

  context 'a visitor' do
    it 'must login before accessing the controller' do
      get '/admin/reserved_words'
      expect(response.status).to redirect_to(login_url)
    end
  end
end
