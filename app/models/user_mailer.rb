class UserMailer < ActionMailer::Base
  include ActionController::UrlWriter
  @@mail_from = "support@alonetone.com"
  mattr_accessor :mail_from

  def forgot_password(user)
    setup_email(user)
    @subject += 'Change your alonetone password'
    @body[:url] = "http://#{ALONETONE.url}/activate/#{user.activation_code}"
  end
  
  def signup(user)
    setup_email(user)
    @body[:url] = "http://#{ALONETONE.url}/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your alonetone account has been activated!'
    @body[:url]  = "http://#{ALONETONE.url}/#{user.login}"
  end    

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "#{ALONETONE.email}"
      @subject     = "[#{ALONETONE.url}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
