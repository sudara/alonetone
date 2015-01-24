module Greenfield
  class Post < ActiveRecord::Base
    attr_accessible :body

    belongs_to :asset
  end
end
