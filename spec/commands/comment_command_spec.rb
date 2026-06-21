require 'rails_helper'

RSpec.describe CommentCommand do
  let(:asset) { assets(:valid_mp3) }
  let!(:comment) { Comment.create!(commentable: asset, commenter: users(:arthur), body: 'a real comment') }

  describe '#spam_and_soft_delete' do
    before { akismet_stub_submit_spam }

    it 'marks spam, soft-deletes, and decrements the cached counts' do
      expect { described_class.new(comment).spam_and_soft_delete }
        .to change { asset.reload.comments_count }.by(-1)
        .and change { asset.user.reload.comments_count }.by(-1)

      spammed = Comment.with_deleted.find(comment.id)
      expect(spammed.is_spam).to be(true)
      expect(spammed.soft_deleted?).to be(true)
    end

    it 'does not decrement again when run on an already-spammed comment' do
      described_class.new(comment).spam_and_soft_delete

      expect { described_class.new(Comment.with_deleted.find(comment.id)).spam_and_soft_delete }
        .not_to change { asset.reload.comments_count }
    end
  end

  describe '#unspam_and_restore' do
    before do
      akismet_stub_submit_spam
      akismet_stub_submit_ham
      described_class.new(comment).spam_and_soft_delete
    end

    it 'restores, unspams, and re-increments the cached counts' do
      expect { described_class.new(Comment.with_deleted.find(comment.id)).unspam_and_restore }
        .to change { asset.reload.comments_count }.by(1)
        .and change { asset.user.reload.comments_count }.by(1)

      restored = comment.reload
      expect(restored.is_spam).to be(false)
      expect(restored.soft_deleted?).to be(false)
    end

    it 'does not over-increment when run on an already-live comment' do
      described_class.new(Comment.with_deleted.find(comment.id)).unspam_and_restore

      expect { described_class.new(comment.reload).unspam_and_restore }
        .not_to change { asset.reload.comments_count }
    end
  end
end
