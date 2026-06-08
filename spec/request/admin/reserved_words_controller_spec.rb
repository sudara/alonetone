require 'rails_helper'

RSpec.describe Admin::ReservedWordsController, type: :request do
  context 'an admin' do
    before do
      create_user_session(users(:sudara))
    end

    it 'sees an overview of all reserved words' do
      get '/admin/reserved_words'
      expect(response).to have_http_status(:ok)
      expect(response.body).to match_css('table')
      ReservedWord.find_each do |word|
        expect(response.body).to include(word.name)
      end
    end

    it 'sees a form to create a new reserved word' do
      get '/admin/reserved_words/new'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Create a new reserved word')
      expect(response.body).to match_css('form')
    end

    describe '#destroy' do
      it "deletes the reserved word" do
        expect {
          delete admin_reserved_word_path(reserved_words(:petaq))
        }.to change(ReservedWord, :count).by(-1)
      end

      it "redirects back to the reserved words index" do
        delete admin_reserved_word_path(reserved_words(:petaq))
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
