class Group < ActiveRecord::Base
  has_many :memberships
  has_many :users, through: :memberships

  validates_presence_of :name
  validates_presence_of :description

  has_permalink :name

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
