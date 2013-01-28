# -*- encoding : utf-8 -*-
class MakeAdminsModerators < ActiveRecord::Migration
  def self.up
    User.find_all_by_admin(true).each {|u| u.update_attribute :moderator, true}
  end

  def self.down
  end
end
