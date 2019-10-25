module Greenfield
  class Post < ActiveRecord::Base
    belongs_to :asset # alonetone asset
    accepts_nested_attributes_for :asset

    has_one :user, through: :asset
    delegate :to_param, :title, to: :asset

    has_many :attached_assets, dependent: :destroy # embedded assets

    accepts_nested_attributes_for :asset # need to update title in greenfield
    accepts_nested_attributes_for :attached_assets

    validates_presence_of :asset
    validate do |post|
    end
  end
end
