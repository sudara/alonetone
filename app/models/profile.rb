class Profile < ApplicationRecord
  belongs_to :user
  validates :user, presence: true

  def has_links?
    bio.present? || website.present? || spotify.present? ||
      twitter.present? || apple.present? || instagram.present?
  end
end

# == Schema Information
#
# Table name: profiles
#
#  id         :bigint(8)        not null, primary key
#  apple      :string(255)
#  bandcamp   :string(255)
#  bio        :text(65535)
#  city       :string(255)
#  country    :string(255)
#  instagram  :string(255)
#  spotify    :string(255)
#  twitter    :string(255)
#  user_agent :string(255)
#  website    :string(255)
#  updated_at :datetime
#  user_id    :integer
#
# Indexes
#
#  index_profiles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
