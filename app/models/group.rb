class Group < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships

  validates_presence_of :name
  validates_presence_of :description

  include Slugs
  has_slug :permalink, from_attribute: :name

  def to_param
    permalink
  end
end

# == Schema Information
#
# Table name: groups
#
#  id          :integer          not null, primary key
#  description :text(16777215)
#  name        :string(255)
#  permalink   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
