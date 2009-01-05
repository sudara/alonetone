class AssetObserver < ActiveRecord::Observer
  def after_create(asset)
    if followers_exist_for?(asset)
      AssetMailer.deliver_upload_notification(asset,emails_of_followers(asset)) 
    end
  end
  
  protected
  
  def followers_exist_for?(asset)
    emails_of_followers(asset).size > 0
  end
  
  def emails_of_followers(asset)
    followers_of(asset).inject([]) do |emails, follower| 
      emails << follower.email if user_wants_email?(follower)
      emails
    end 
  end
  
  def followers_of(asset)
    asset.user.followers
  end
  
  def user_wants_email?(user)
    # anyone who doesn't have it set to false, aka, opt-out
    (user.settings == nil) || (user.settings[:email_new_tracks] != "false")
  end
end
