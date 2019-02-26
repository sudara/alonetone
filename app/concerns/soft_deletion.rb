require 'active_support/concern'

module SoftDeletion
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted_at: nil) }

    scope :only_deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }
    scope :with_deleted, -> { unscope(where: :deleted_at) }
  end
end