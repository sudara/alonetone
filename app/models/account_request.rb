# frozen_string_literal: true

class AccountRequest < ApplicationRecord

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
      denied: 2
    }
  )

  validates :entity_type, inclusion: {
    in: entity_types,
    message: "We'd like to know what sort of thing you want to upload!"
  }

  validates :email,
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "should look like an email address."
    }
  validate :email_is_unique

  validates :login,
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
end