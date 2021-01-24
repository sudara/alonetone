# frozen_string_literal: true

class MassInvite < ApplicationRecord
  scope :recent, -> { order(created_at: :desc, id: :desc) }

  after_initialize :set_token, if: :new_record?

  validates :name, :token, presence: true

  def to_param
    token
  end

  private

  def set_token
    self.token ||= SecureRandom.alphanumeric(16)
  end
end
