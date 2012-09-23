# -*- encoding : utf-8 -*-
class DropOvercomplicatedCommentsIndex < ActiveRecord::Migration
  def self.up
    remove_index "comments", ["commentable_id","commentable_type"]
    add_index "comments", ["commentable_id"]
  end

  def self.down
  end
end
