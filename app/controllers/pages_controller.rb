require 'bluecloth'

class PagesController < ApplicationController

  class Fuck < StandardError; end

  def index
    @page_title = "About alonetone, the kickass home for musicians"
  end

  def home
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
