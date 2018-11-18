class Profile < ApplicationRecord
  belongs_to :user
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
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
