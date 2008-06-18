module ForumsHelper
 def pagination(collection)
    if collection.total_pages > 1
      "<p class='pages'>" + 'Pages'[:pages_title] + ": <strong>" + 
      will_paginate(collection, :inner_window => 10, :next_label => "next"[], :prev_label => "previous"[]) +
      "</strong></p>"
    end
  end
  
  def next_page(collection)
    unless collection.current_page == collection.total_pages or collection.total_pages == 0
      "<p style='float:right;'>" + link_to("Next page"[], { :page => collection.current_page.next }.merge(params.reject{|k,v| k=="page"})) + "</p>"
    end
  end

  def search_posts_title
    returning(params[:q].blank? ? 'Recent Posts'[] : "Searching for"[] + " '#{h params[:q]}'") do |title|
      title << " "+'by {user}'[:by_user,h(@user.display_name)] if @user
      title << " "+'in {forum}'[:in_forum,h(@forum.name)] if @forum
    end
  end

  def topic_title_link(topic, options)
    if topic.title =~ /^\[([^\]]{1,15})\]((\s+)\w+.*)/
      "<span class='flag'>#{$1}</span>" + 
      link_to(h($2.strip), forum_topic_path(@forum, topic), options)
    else
      link_to(h(topic.title), forum_topic_path(@forum, topic), options)
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

  def topic_count(topics)
    pluralize topics.size, 'topic'
  end
  
  def post_count(posts)
    pluralize posts.size, 'post'
  end
  
  # Ripe for optimization
  def voice_count
    pluralize current_site.topics.to_a.sum { |t| t.voice_count }, 'voice'
  end

end
