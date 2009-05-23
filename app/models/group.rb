class Group < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships

  validates_presence_of :name
  validates_presence_of :description
  
  has_permalink :name
  before_save :create_unique_permalink
  
  def to_param
    permalink
  end
  
end
