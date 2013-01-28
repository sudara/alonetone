# -*- encoding : utf-8 -*-
class SetListensCountToZero < ActiveRecord::Migration
  def self.up
    Asset.find(:all).each do |a|
      a.listens_count = 0 if !a.listens_count
    end
    User.find(:all).each do |a|
      a.listens_count = 0 if !a.listens_count
    end
    
    add_index :listens, :listener_id
    add_index :listens, :track_owner_id
  end

  def self.down
  end
end
