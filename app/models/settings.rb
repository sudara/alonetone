class Settings < ApplicationRecord
  belongs_to :user
  delegate :display_listen_count?, :block_guest_comments?, :most_popular?,
    :increase_ego?, :email_comments?, :email_new_tracks?, to: :user
end
