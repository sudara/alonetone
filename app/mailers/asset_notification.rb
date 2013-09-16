class AssetNotification < ActionMailer::Base
  default :from => Alonetone.email

  def upload_notification(asset, emails, sent_at = Time.now)
    mail :subject => "[alonetone] '#{asset.user.name}' uploaded a new track!", :bcc => emails.join(', ')
    
    @track = asset.name
    @name =  asset.user.name
    @download_link = download_link_for(asset)
    @play_link = play_link_for(asset)
    @user_link = user_link_for(asset)
    @exclamation = ["Sweet", "Yes", "Oooooh", "Alright", "Booya", "Yum","Celebrate", "OMG"].sample
  end

  protected
  
  def user_link_for(asset)
    'http://' + Alonetone.url + '/' + asset.user.login
  end
  
  def play_link_for(asset)
    user_link_for(asset) + '/tracks/' + asset.id.to_s
  end
  
  def download_link_for(asset)
    play_link_for(asset) + '.mp3?source=email'
  end

end
