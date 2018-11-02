class Admin::BaseController < ApplicationController
  include Pagy::Backend
  before_action :moderator_only
end
