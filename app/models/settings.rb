class Settings < ApplicationRecord
  belongs_to :user
  validates :user, presence: true

  AVAILABLE = %i[display_listen_count? block_guest_comments? most_popular?
    increase_ego? email_comments? email_new_tracks?].freeze
end

# == Schema Information
#
# Table name: settings
#
#  id                   :bigint(8)        not null, primary key
#  block_guest_comments :boolean          default(FALSE)
#  display_listen_count :boolean          default(TRUE)
#  email_comments       :boolean          default(TRUE)
#  email_new_tracks     :boolean          default(TRUE)
#  increase_ego         :boolean          default(FALSE)
#  most_popular         :boolean          default(TRUE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint(8)
#
# Indexes
#
#  index_settings_on_user_id  (user_id)
#
