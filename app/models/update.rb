class Update < ActiveRecord::Base
    
  has_permalink :title
  scope :recent, -> { order('created_at DESC') }
    
  attr_accessible :title, :content
  has_many :comments, :as => :commentable, :dependent => :destroy
  
  # The following methods help us keep dry w/ comments
  def name
    "blog: #{self.title}"
  end
  
  def full_permalink
    "http://#{Alonetone.url}/blog/#{permalink}"
  end
  
end
