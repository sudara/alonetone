# -*- encoding : utf-8 -*-
class UserNotification < ActionMailer::Base
  default :from => Alonetone.email

  def forgot_password(user)
    @url = "http://#{Alonetone.url}/activate/#{user.activation_code}"
    mail :to => user.email, :subject => "[#{Alonetone.url}] Change your password"
  end
  
  def signup(user)
    @url = "http://#{Alonetone.url}/activate/#{user.activation_code}"
    mail :to => user.email, :subject => "[#{Alonetone.url}] Welcome!"  
  end
  
  def activation(user)
    @url = "http://#{Alonetone.url}/#{user.login}"
    mail :to => user.email, :subject => "[#{Alonetone.url}] Your account has been activated!"  

  end    
end
