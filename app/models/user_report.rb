class UserReport < ActiveRecord::Base
  
  named_scope :valid, {:conditions => {:spam => :false}}

  validates_presence_of :description, :category
  belongs_to :user
  serialize :params
  
  formats_attributes :content
  acts_as_defensio_comment :fields => { :content => :description, :author => :user }
  
  def article
    UserReport.find(:first)
  end
  
  def print
    self.description_html || BlueCloth::new(self.description).to_html
  end
  
end

