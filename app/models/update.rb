require 'bluecloth'
class Update < ActiveRecord::Base
  
  formats_attributes :content
  
  has_permalink :title
  before_save :create_unique_permalink
  
  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'
  
  def print
    self.content_html || BlueCloth::new(self.content).to_html
  end
  
    # The following methods help us keep dry w/ comments
  def name
    "blog: #{self.title}"
  end
  
  alias :unique_id :id  
end
