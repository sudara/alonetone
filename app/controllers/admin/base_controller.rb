module Admin
  class BaseController < ApplicationController
    include Pagy::Backend
    before_action :moderator_only
  end
end
