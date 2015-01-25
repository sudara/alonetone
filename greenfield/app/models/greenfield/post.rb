module Greenfield
  class Post < ActiveRecord::Base
    attr_accessible :body

    belongs_to :asset # alonetone asset
    has_one :user, :through => :asset
    delegate :to_param, :title, :to => :asset

    has_many :attached_assets # embedded assets
    accepts_nested_attributes_for :attached_assets
    attr_accessible :attached_assets_attributes
  end
end
