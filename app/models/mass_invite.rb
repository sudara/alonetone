# frozen_string_literal: true

class MassInvite < ApplicationRecord
  scope :recent, -> { order(created_at: :desc, id: :desc) }

  after_initialize :set_token, if: :new_record?

  has_many :mass_invite_signups
  has_many :users, through: :mass_invite_signups

  validates :name, :token, presence: true

  def to_param
    token
  end

  private

  def set_token
    self.token ||= SecureRandom.alphanumeric(16)
  end
end

# == Schema Information
#
# Table name: mass_invites
#
#  id          :bigint(8)        not null, primary key
#  archived    :boolean          default(FALSE), not null
#  name        :text(65535)      not null
#  token       :string(255)      not null
#  users_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_mass_invites_on_token  (token) UNIQUE
#
