require 'rails_helper'

RSpec.describe DeletedUserCleanupJob, type: :job do
  describe "soft_deleted user" do
    subject(:job) { described_class.perform_later(users(:arthur).id) }

    before do
      users(:arthur).soft_delete_relations
      users(:arthur).soft_delete
    end

    it "queues the job" do
      expect { job }.to have_enqueued_job(described_class)
        .with(users(:arthur).id)
        .on_queue("default")
    end

    it "should really delete a user" do
      perform_enqueued_jobs do
        expect(User.where(login: 'arthur').first).to be_nil
        job
      end
      assert_performed_jobs 1
    end

    it "should really delete all of user's associations" do
      perform_enqueued_jobs do
        expect(Asset.where(user_id: users(:arthur).id)).to be_empty
        expect(Comment.where(user_id: users(:arthur).id)).to be_empty
        expect(Topic.where(user_id: users(:arthur).id)).to be_empty
        expect(Listen.where(track_owner_id: users(:arthur).id)).to be_empty
        expect(Listen.where(listener_id: users(:arthur).id)).to be_empty
        expect(Track.where(user_id: users(:arthur).id)).to be_empty
        expect(Playlist.where(user_id: users(:arthur).id)).to be_empty
        job
      end
      assert_performed_jobs 1
    end
  end

  describe "not soft deleted user" do
    subject(:job) { described_class.perform_later(id) }

    describe "user exists" do
      let!(:id) { users(:arthur).id }

      it "should not delete a user that has not been soft deleted" do
        perform_enqueued_jobs do
          expect(User.where(login: 'arthur').first).not_to be_nil
          job
        end
        assert_performed_jobs 1
      end
    end

    describe "user does not exist" do
      let!(:id) { 99999 }

      it "raises no error" do
        perform_enqueued_jobs do
          expect { job }.not_to raise_error
        end
        assert_performed_jobs 1
      end
    end
  end
end
