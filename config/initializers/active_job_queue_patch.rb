if Rails.application.config.active_job.queue_adapter == :inline
  ActiveJob::Base
  module ActiveJob::Core::ClassMethods
    def set_with_no_delays(options={}, &block)
      options.delete(:wait)
      options.delete(:wait_until)
      set_without_no_delays(options, &block)
    end

    alias_method_chain :set, :no_delays
  end
end

