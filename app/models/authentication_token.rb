# frozen_string_literal: true

class AuthenticationToken < ApplicationRecord
  after_initialize :set_defaults, if: :new_record?

  enum purpose: { password_reset: 0 }

  belongs_to :user

  def to_param
    token
  end

  private

  def set_defaults
    self.token ||= SecureRandom.alphanumeric(32)
    self.valid_until ||= 24.hours.from_now
  end
end
