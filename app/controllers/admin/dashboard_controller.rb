module Admin
  class DashboardController < Admin::BaseController
    def index
      @admin_title = 'Dashboard'
      @admin_range_enabled = true
      @stats = Admin::DashboardStats.new(range: admin_range, bucket: admin_bucket, range_key: admin_range_key)
    end
  end
end
