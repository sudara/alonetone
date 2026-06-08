class AdminController < ApplicationController
  include Admin::Range

  layout 'admin'
  before_action :moderator_only

  def index
    @admin_title = 'Dashboard'
    @admin_range_enabled = true
    @stats = Admin::DashboardStats.new(range: admin_range, bucket: admin_bucket)
  end
end
