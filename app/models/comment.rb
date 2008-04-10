class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true

  # optional user who made the comment
  belongs_to :commenter, :class_name => 'User'

  # optional user who is recieving the comment
  # this helps simplify a user lookup of all comments across tracks/playlists/whatever
  belongs_to :user
  
  validates_length_of :body, :within => 1..700
  
  acts_as_defensio_comment :fields => { :content => :body, :article => :commentable, :author => :commenter }
  attr_accessor :current_user

  
  def body
    BlueCloth::new(self[:body]).to_html
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
  
end
