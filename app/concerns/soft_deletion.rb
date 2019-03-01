require 'active_support/concern'

module SoftDeletion
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }

    scope :only_deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
    scope :with_deleted, -> { unscope(where: :deleted_at) }

    def soft_delete
      update_attribute('deleted_at', Time.now)
    end

    def soft_deleted?
      deleted_at != nil
    end

    # would like to be able to skip any validation
    def restore
      update_attribute('deleted_at', nil)
    end
  end
end
