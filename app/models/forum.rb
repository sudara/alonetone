class Forum < ActiveRecord::Base
  scope :ordered, -> { order(position: :asc) }
  scope :with_topics, -> { preload(:recent_post).preload(:recent_topic) }

  acts_as_list
  has_permalink :name

  validates_presence_of :name
  attr_readonly :posts_count, :topics_count

  has_many :topics, dependent: :delete_all
  has_many :posts, dependent: :delete_all

  has_one  :recent_topic,
    -> { not_spam.recent },
    class_name: "Topic"

  has_one :recent_post,
  -> { not_spam.order('created_at DESC') },
  class_name: "Post"

  def to_param
    permalink
  end
end

# == Schema Information
#
# Table name: forums
#
#  id               :integer          not null, primary key
#  description      :string(255)
#  description_html :text(16777215)
#  name             :string(255)
#  permalink        :string(255)
#  position         :integer          default(1)
#  posts_count      :integer          default(0)
#  state            :string(255)      default("public")
#  topics_count     :integer          default(0)
#  site_id          :integer
#
# Indexes
#
#  index_forums_on_permalink  (permalink)
#  index_forums_on_position   (position)
#
