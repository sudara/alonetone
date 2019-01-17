class Update < ApplicationRecord
  has_permalink :title
  scope :recent, -> { order('created_at DESC') }

  has_many :comments, as: :commentable, dependent: :destroy

  # The following methods help us keep dry w/ comments
  def name
    "blog: #{title}"
  end

  def full_permalink
    "https://#{hostname}/blog/#{permalink}"
  end
end

# == Schema Information
#
# Table name: updates
#
#  id           :integer          not null, primary key
#  content      :text(16777215)
#  content_html :text(16777215)
#  permalink    :string(255)
#  revision     :integer
#  title        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#
