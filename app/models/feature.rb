class Feature < ActiveRecord::Base

  named_scope :published, {:conditions => {:published_true}}


  belongs_to :writer, :class_name => 'User'
  belongs_to :featured_user, :class_name => 'User'
  
  validates_presence_of :writer, :featured_user
  
  before_save :create_permalink
  
  def body
    BlueCloth::new(self[:body]).to_html
  end
  
  protected
  
  def create_permalink
    permalink = featured_user.login
  end
  
  def publish
    update_attributes(:published => true, :published_at => Time.now)
  end
end
