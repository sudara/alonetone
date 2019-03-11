class UserNotification < ApplicationMailer
  def forgot_password(user)
    @user = user
    @url = edit_password_reset_url(@user.perishable_token)
    mail to: user.email, subject: "[#{hostname}] Change your password"
  end

  def signup(user)
    @user = user
    set_activation_url
    mail to: user.email, subject: "[#{hostname}] Welcome!"
  end

  def activation(user)
    @url = "https://#{hostname}/#{user.login}"
    mail to: user.email, subject: "[#{hostname}] Your account has been activated!"
  end

  protected

  def set_activation_url
    @url = "https://#{hostname}/activate/#{@user.perishable_token}"
  end
end
