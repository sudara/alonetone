class Patron < ApplicationRecord
  belongs_to :user
end

# == Schema Information
#
# Table name: patrons
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime
#  user_id    :integer          not null
#
# Indexes
#
#  index_patrons_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
