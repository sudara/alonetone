# frozen_string_literal: true

# Implements a few methods that controllers can use to respond after initializing a new user record.
module UserCreation
  protected

  # The user argument should be a User instance that is not persisted yet. The method will save
  # the user record, send a confirmation email, and generate a response. The user is not saved
  # when the request or user attributes look like spam.
  def respond_with_user(user)
    if user.valid?
      respond_with_valid_user(user)
    else
      render :new
    end
  end

  private

  def respond_with_valid_user(user)
    # When the user agent or remote IP address indicates that this request is spam.
    if is_a_bot?
      Rails.logger.info('Based on remote IP or user-agent this looks like a spammer.')
    # When any of the  user attributes values indicate that this user was created by spammers.
    elsif user.spam?
      Rails.logger.info('Based on user attributes this looks like a spammer.')
    else
      # Sets the perishable token used for email confirmation and saves the record.
      user.reset_perishable_token!
      UserNotification.signup(user).deliver_now
    end
    redirect_to login_url(already_joined: true)
  end
end
