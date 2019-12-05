class InviteNotification < ApplicationMailer
  def approved_request(user)
    @user = user
    @password_url = edit_password_reset_url(@user.perishable_token)
    @profile_url = edit_user_url(@user)
    mail to: user.email, subject: "[#{hostname}] Your account was approved. Welcome!"
  end
end
