# -*- encoding : utf-8 -*-
require 'bluecloth'
class Comment < ActiveRecord::Base
  
  scope :public, where(:spam => false).where(:private => false).order('id DESC')  
  scope :by_member, where('commenter_id IS NOT NULL')
  
  scope :include_private, where(:spam => false)
  
  belongs_to :commentable, :polymorphic => true, :touch => true
  
  has_many :replies, 
    :as         => :commentable, 
    :class_name => 'Comment'

  # optional user who made the comment
  belongs_to :commenter, :class_name => 'User'

  # optional user who is recieving the comment
  # this helps simplify a user lookup of all comments across tracks/playlists/whatever
  belongs_to :user
  
  validates_length_of :body, :within => 1..2000
  
  
  
  include Defender::Spammable
  configure_defender :keys => { 'content' => :body, 
    'type' => 'comment', 'author-ip' => :remote_ip, 'author-name' => :author_name,
    'parent-document-permalink' => :full_permalink}
  
  attr_accessor :current_user

  def body
    self.body_html || BlueCloth::new(self[:body]).to_html
  end
  
  def duplicate?
    Comment.find_by_remote_ip_and_body(self.remote_ip, self.body)
  end
  
  def author_name
    if commenter
      commenter.login
    else
      'guest'
    end
  end
  
  def full_permalink
    commentable.full_permalink
  end
  
  def user_logged_in
    !!commenter_id 
  end
  
  def trusted_user
    commenter_id && commenter.moderator?
  end
  
  # for montgomeru magic
  def self.count_by_user(start_date, end_date, limit=30)
    limit = limit > 100 ? 100 : limit
    Comment.public.count(:all, :group => :commenter, :conditions => ['created_at > ? AND created_at < ? AND commenter_id IS NOT NULL',start_date, end_date], :limit => limit, :order => 'count_all DESC')
  end
end
