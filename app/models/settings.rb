class Settings < ApplicationRecord
  belongs_to :user
  AVAILABLE = %i[display_listen_count? block_guest_comments? most_popular?
    increase_ego? email_comments? email_new_tracks?].freeze
end
