module SoftDeletion
  extend ActiveSupport::Concern

  # how long a record stays soft-deleted before it may be permanently destroyed
  GRACE_PERIOD = 30.days

  included do
    default_scope { where(deleted_at: nil) }

    scope :only_deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
    scope :with_deleted, -> { unscope(where: :deleted_at) }
    scope :destroyable,  -> { only_deleted.where('deleted_at < ?', GRACE_PERIOD.ago) }

    # doesn't validate the record, calls callbacks and saves
    def soft_delete
      update_attribute(:deleted_at, Time.now)
    end

    def soft_deleted?
      deleted_at != nil
    end

    def perma_deletable?
      soft_deleted? && deleted_at < GRACE_PERIOD.ago
    end

    # would like to be able to skip any validation
    def restore
      update_attribute(:deleted_at, nil)
    end
  end
end
