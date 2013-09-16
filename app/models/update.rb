# -*- encoding : utf-8 -*-
class Update < ActiveRecord::Base
    
  has_permalink :title
  
  #acts_as_defensio_article_article(:fields =>{:permalink => :full_permalink})
  
  has_many :comments,
    -> { order('created_at ASC')},
    :as => :commentable, 
    :dependent => :destroy
  
  def print
    self.content_html || BlueCloth::new(self.content).to_html
  end
  
    # The following methods help us keep dry w/ comments
  def name
    "blog: #{self.title}"
  end
  
  def full_permalink
    "http://#{Alonetone.url}/blog/#{permalink}"
  end
  
end
