Saulabs::Reportable::ReportCache.send(:attr_accessible, :model_class_name, :report_name, :grouping, :aggregation, :conditions, :reporting_period, :value)

module Saulabs
  module Reportable
    module ReportTagHelper
      alias_method :lib_raphael_report_tag, :raphael_report_tag

      def raphael_report_tag(*args)
        raphael = lib_raphael_report_tag(*args)
        raphael.sub(/(<script[^>]*>)(.+)(<\/script>)/m,
                    "\\1\ndocument.addEventListener('DOMContentLoaded', function() {\n\\2\n}, false);\n\\3")
      end
    end
  end
end
