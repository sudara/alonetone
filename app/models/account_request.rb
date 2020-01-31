# frozen_string_literal: true

class AccountRequest < ApplicationRecord
  scope :recent, -> { order('created_at DESC') }

  belongs_to :user, optional: true
  belongs_to :moderated_by, optional: true, class_name: 'User'

  enum(
    entity_type: {
      band: 0,
      musician: 1,
      label: 2,
      blogger: 3,
      podcaster: 4
    }
  )

  enum(
    status: {
      waiting: 0,
      approved: 1,
      denied: 2,
      accepted: 3
    }
  )

  validates :entity_type, inclusion: {
    in: entity_types,
    message: "We need to know what sort of thing you want to upload!"
  }

  validates :email,
    on: :create,
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "should look like an email address."
    }
  validate :email_is_unique, on: :create

  validates :login,
    on: :create,
    format: {
      with: /\A\w+\z/,
      message: "should use only letters and numbers."
    }
  validate :login_is_unique, on: :create

  validates :details, length: {
    minimum: 40,
    too_short: "must be at least 40 characters: Please link to your music/website or add more info!"
  }

  def email_is_unique
    if User.where(email: email).exists?
      errors.add(:email, "You already have an account on alonetone!")
    end
  end

  def login_is_unique
    if User.where(login: login).exists?
      errors.add(:login, "Sorry, login is taken. Be creative!")
    end
  end

  def approve!(approved_by)
    return unless approved_by.moderator?

    approved! && update(moderated_by: approved_by)
    create_user_account!(approved_by)
  end

  def create_user_account!(invited_by)
    User.create!(login: login, email: email, invited_by: invited_by) do |u|
      u.reset_password
      u.reset_perishable_token
    end
  end

  def self.filter_by(status)
    if status.present?
      recent.where(status: status)
    else
      recent
    end
  end
end

# == Schema Information
#
# Table name: account_requests
#
#  id              :bigint(8)        not null, primary key
#  details         :text(65535)
#  email           :string(255)
#  entity_type     :integer
#  login           :string(255)
#  status          :integer          default("waiting")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  moderated_by_id :integer
#
