module ForumsHelper
  
  def search_posts_title
   title = (params[:q].blank? ? 'Recent Posts': "Searching for" + " '#{h params[:q]}'") 
   title << " "+'by {user}'[:by_user,h(@user.display_name)] if @user
   title << " "+'in {forum}'[:in_forum,h(@forum.name)] if @forum
  end

  def topic_title_link(topic, options)
    if topic.title =~ /^\[([^\]]{1,15})\]((\s+)\w+.*)/
      "<span class='flag'>#{$1}</span>".html_safe + 
      link_to($2.strip, forum_topic_path((@forum || topic.forum), topic), options)
    else
      link_to(topic.title, forum_topic_path((@forum || topic.forum), topic), options)
    end
  end
  
  # used to know if a topic has changed since we read it last
  def recent_topic_activity(topic)
    return false unless logged_in?
    return topic.last_updated_at > ((session[:topics] ||= {})[topic.id] || (session[:last_active] ||= Time.now.utc))
  end 

  # used to know if a forum has changed since we read it last
  def recent_forum_activity(forum)
    return false unless logged_in? && forum.recent_topic
    return forum.recent_topic.last_updated_at > ((session[:forums] ||= {})[forum.id] || (session[:last_active] ||= Time.now.utc))
  end
  
  def search_posts_title
    title = (params[:q].blank? ? 'Recent Posts' : "Searching for" + " '#{h params[:q]}'") 
    title << " by #{h(@user.display_name)}" if @user
    title << " in #{@forum.name}" if @forum
  end

end
