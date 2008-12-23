require 'bluecloth'

class PagesController < ApplicationController
  skip_filter filter_chain, :only => :help_an_app_support_brutha_out
  class Hell < StandardError; end

  def twentyfour
    render :layout => '24houralbum'
  end

  def index
    @page_title = "About alonetone, the kickass home for musicians"
  end

  def home
  
  end
  
  def error
    @page_title = "Whups, alonetone slipped and fell!"
    flash[:error] = "We have a problem. But, it is not you...it's me."
  end
  
  def four_oh_four
    @page_title = "Not found"
    flash[:error] = "Gone looking but did not find? Try searching, or let us know!"
  end

  def help_an_app_support_brutha_out
    query      = "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1"
    version    = ActiveRecord::Base.connection.select_value(query)
    time       = Time.now.to_formatted_s(:rfc822)
    render(:text => "O Hai. You can haz alonetone. kthxbai!")
  end

  def about
    @page_title = "About alonetone, the kickass home for musicians"
  end
  
  def stats
    @page_title = "Listening and Song Statistics"
    @number_of_musicians = User.musicians.count
    @comments_per_user = User.average('comments_count').ceil
    @average_length_of_track = Asset.formatted_time(Asset.average('length').ceil)
    @listens_per_track = Asset.average('listens_count').ceil
    @listens_per_user = User.average('listens_count').ceil
    @tracks_per_user = User.average('assets_count').ceil
    @listens_per_week_per_track = Asset.average('listens_per_week').ceil
    @posts_per_user = User.average('posts_count')
  end
  
  def actually_going_somewhere_with_facebooker_and_rails
    render :partial => 'facebooker', :layout => true
  end

  def answers
    raise Hell
  end
  
  def not_yet
    render :layout => false
  end
  
  def itunes
    @page_title = "How to get your music on iTunes (as a music podcast) with alonetone"
  end
  
  def sitemap
    @users = User.find(:all)
    respond_to do |wants|
      wants.xml
    end
  end
end
