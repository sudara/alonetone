# -*- encoding : utf-8 -*-
class AddItunesToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :itunes, :string
  end

  def self.down
  end
end
