class UserReport < ActiveRecord::Base
  validates_presence_of :description, :category
  belongs_to :user
  serialize :params
  acts_as_defensio_comment :fields => { :content => :description, :author => :user }
  
  def article
    UserReport.find(:first)
  end
  
end

