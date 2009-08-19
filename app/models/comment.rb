require 'bluecloth'
class Comment < ActiveRecord::Base
  
  named_scope :public, {
    :conditions => {:spam => false, :private => :false},
    :order      => 'id DESC'
  }
  
  named_scope :include_private, {
    :conditions => {:spam => false}, 
    :order      => 'id DESC'
  }
  
  belongs_to :commentable, :polymorphic => true
  
  has_many :replies, 
    :as         => :commentable, 
    :class_name => 'Comment'

  # optional user who made the comment
  belongs_to :commenter, :class_name => 'User'

  # optional user who is recieving the comment
  # this helps simplify a user lookup of all comments across tracks/playlists/whatever
  belongs_to :user
  
  validates_length_of :body, :within => 1..2000
  
  formats_attributes :body
  
  acts_as_defensio_comment(:fields => { 
    :content  => :body, 
    :article  => :commentable, 
    :author   => :commenter 
  })
  
  attr_accessor :current_user

  def body
    self.body_html || BlueCloth::new(self[:body]).to_html
  end
  
  def duplicate?
    Comment.find_by_remote_ip_and_body(self.remote_ip, self.body)
  end
  
  def user_logged_in
    commenter_id 
  end
  
  def trusted_user
    commenter_id && commenter.admin?
  end
  
  # for montgomeru magic
  def self.count_by_user(start_date, end_date, limit=30)
    limit = limit > 100 ? 100 : limit
    Comment.public.count(:all, :group => :commenter, :conditions => ['created_at > ? AND created_at < ? AND commenter_id IS NOT NULL',start_date, end_date], :limit => limit, :order => 'count_all DESC')
  end
end
