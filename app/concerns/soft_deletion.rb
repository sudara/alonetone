require 'active_support/concern'

module SoftDeletion
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }

    scope :only_deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
    scope :with_deleted, -> { unscope(where: :deleted_at) }

    def soft_delete
      self.update_attributes(deleted_at: Time.now)
    end
  end
end