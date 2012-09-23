# -*- encoding : utf-8 -*-
class AddCommenterIdIndexToComments < ActiveRecord::Migration
  def self.up
    add_index :comments, :commenter_id
  end

  def self.down
  end
end
