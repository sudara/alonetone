module Admin
  module Range
    extend ActiveSupport::Concern

    RANGES = {
      "7d" => { label: "7d", duration: 7.days },
      "30d" => { label: "30d", duration: 30.days },
      "1y" => { label: "1y", duration: 365.days },
      "all" => { label: "All", duration: nil }
    }.freeze

    DEFAULT_RANGE = "30d".freeze

    included do
      helper_method :admin_range_key, :admin_range, :admin_range_options
    end

    private

    def admin_range_key
      @admin_range_key ||= begin
        key = params[:range].presence || session[:admin_range] || DEFAULT_RANGE
        key = DEFAULT_RANGE unless RANGES.key?(key)
        session[:admin_range] = key
        key
      end
    end

    def admin_range
      duration = RANGES.fetch(admin_range_key)[:duration]
      duration && (duration.ago..Time.current)
    end

    def admin_range_options
      RANGES
    end
  end
end
