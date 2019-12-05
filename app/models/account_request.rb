# frozen_string_literal: true

class AccountRequest < ApplicationRecord
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
    message: "We'd like to know what sort of thing you want to upload!"
  }

  validates :email,
    on: :create,
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "should look like an email address."
    }
  validate :email_is_unique

  validates :login,
    on: :create,
    format: {
      with: /\A\w+\z/,
      message: "should use only letters and numbers."
    }
  validate :login_is_unique

  validates :details, length: {
    minimum: 5,
    too_short: "Please link to your music/website or add some detail about what you make!"
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
    User.create(login: login, email: email, invited_by: invited_by) do |u|
      u.reset_password
      u.reset_perishable_token
    end
  end
end
