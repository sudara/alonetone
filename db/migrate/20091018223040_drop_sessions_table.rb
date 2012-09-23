# -*- encoding : utf-8 -*-
class DropSessionsTable < ActiveRecord::Migration
  def self.up
    drop_table :sessions
  end

  def self.down
  end
end
