require 'rails_helper'

RSpec.describe Admin::DevopsController, type: :request do
  describe 'as an admin' do
    before { create_user_session(users(:sudara)) }

    it 'renders the devops panel with tools and the sweep counts' do
      get admin_devops_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Perma-delete sweep')
      expect(response.body).to include('Job status')
    end

    it 'queues the purge sweep' do
      expect { post admin_devops_purge_path }.to have_enqueued_job(PurgeEligibleRecordsJob)
    end
  end

  describe 'as a moderator (not admin)' do
    before { create_user_session(users(:sandbags)) }

    it 'cannot trigger the purge sweep (admin-only)' do
      expect { post admin_devops_purge_path }.not_to have_enqueued_job(PurgeEligibleRecordsJob)
    end
  end
end
