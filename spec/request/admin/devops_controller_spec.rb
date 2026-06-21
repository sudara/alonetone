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

    it 'lists the records eligible for permanent deletion' do
      users(:arthur).update_columns(deleted_at: 40.days.ago)
      assets(:valid_mp3).update_columns(deleted_at: 40.days.ago)
      comment = comments(:public_comment_on_asset_by_user)
      comment.update_columns(deleted_at: 40.days.ago)
      get admin_devops_path
      expect(response.body).to include(users(:arthur).login)
      expect(response.body).to include(assets(:valid_mp3).title)
      expect(response.body).to include(comment.body)
      expect(response.body).to include('comments soft-deleted more than 30 days ago')
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
