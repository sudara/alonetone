# -*- encoding : utf-8 -*-
class AddCommentsCountToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :comments_count, :integer, :default => 0
    Asset.find(:all).each do |a|
      a.update_attribute :comments_count, a.comments.public.count
    end
  end

  def self.down
    drop_column :assets, :comments_count
  end
end
