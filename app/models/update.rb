# == Schema Information
#
# Table name: updates
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  content      :text(65535)
#  created_at   :datetime
#  updated_at   :datetime
#  revision     :integer
#  content_html :text(65535)
#  permalink    :string(255)
#

class Update < ActiveRecord::Base
  has_permalink :title
  scope :recent, -> { order('created_at DESC') }

  has_many :comments, as: :commentable, dependent: :destroy

  # The following methods help us keep dry w/ comments
  def name
    "blog: #{title}"
  end

  def full_permalink
    "https://#{Alonetone.url}/blog/#{permalink}"
  end
end

# == Schema Information
#
# Table name: updates
#
#  id           :integer          not null, primary key
#  content      :text(65535)
#  content_html :text(65535)
#  permalink    :string(255)
#  revision     :integer
#  title        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#
