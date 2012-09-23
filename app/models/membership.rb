# -*- encoding : utf-8 -*-
class Membership < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
end
