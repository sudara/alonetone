class UserNotification < ActionMailer::Base
  default :from => Alonetone.email

  def forgot_password(user)
    @user = user
    set_activation_url
    mail :to => user.email, :subject => "[#{Alonetone.url}] Change your password"
  end
  
  def signup(user)
    @user = user
    set_activation_url
    mail :to => user.email, :subject => "[#{Alonetone.url}] Welcome!"  
  end
  
  def activation(user)
    @url = "http://#{Alonetone.url}/#{user.login}"
    mail :to => user.email, :subject => "[#{Alonetone.url}] Your account has been activated!"  
  end    
  
  
  protected
  
  def set_activation_url
    @url = "http://#{Alonetone.url}/activate/#{@user.perishable_token}"
  end
end
