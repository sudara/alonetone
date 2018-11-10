module Admin
  class BaseController < ApplicationController
    before_action :moderator_only
  end
end
