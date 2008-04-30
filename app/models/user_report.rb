class UserReport < ActiveRecord::Base
  
  named_scope :valid, {:conditions => {:spam => :false}}

  validates_presence_of :description, :category
  belongs_to :user
  serialize :params
  acts_as_defensio_comment :fields => { :content => :description, :author => :user }
  
  def article
    UserReport.find(:first)
  end
  
  def print
    BlueCloth::new(self.description).to_html
  end
  
end

