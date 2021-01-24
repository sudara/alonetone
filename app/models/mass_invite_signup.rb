# frozen_string_literal: true

class MassInviteSignup < ApplicationRecord
  belongs_to :mass_invite, counter_cache: :users_count
  belongs_to :user
end

# == Schema Information
#
# Table name: mass_invite_signups
#
#  id             :bigint(8)        not null, primary key
#  mass_invite_id :bigint(8)
#  user_id        :bigint(8)
#
# Indexes
#
#  index_mass_invite_signups_on_mass_invite_id  (mass_invite_id)
#  index_mass_invite_signups_on_user_id         (user_id)
#
