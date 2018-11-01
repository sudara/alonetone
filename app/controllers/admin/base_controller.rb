class Admin::BaseController < ApplicationController
  before_action :moderator_only
end
