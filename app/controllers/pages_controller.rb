require 'bluecloth'

class PagesController < ApplicationController

  class Fuck < StandardError; end

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

  def about
    @page_title = "About alonetone, the kickass home for musicians"
  end
  
  def actually_going_somewhere_with_facebooker_and_rails
    render :partial => 'facebooker', :layout => true
  end

  def answers
    raise Fuck
  end
  
  def todo
    expire_fragment('todos') if params[:expire]
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
