# frozen_string_literal: true

class MassInviteSignup < ApplicationRecord
  belongs_to :mass_invite, counter_cache: :users_count
  belongs_to :user
end
