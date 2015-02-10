module Greenfield
  class Post < ActiveRecord::Base
    attr_accessible :body

    belongs_to :asset # alonetone asset
    accepts_nested_attributes_for :asset
    attr_accessible :asset_attributes

    has_one :user, :through => :asset
    delegate :to_param, :title, :to => :asset
    
    has_many :attached_assets, :dependent => :destroy # embedded assets
    
    accepts_nested_attributes_for :asset # need to update title in greenfield
    accepts_nested_attributes_for :attached_assets
    attr_accessible :attached_assets_attributes

    validates_presence_of :body
    validates_presence_of :asset
    validate do |post|
      Greenfield::Markdown.invalid_embeds(post).each do |i|
        post.errors[:base] << "Reference to attachment number #{i} is invalid"
      end
    end
  end
end
