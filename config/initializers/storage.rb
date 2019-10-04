# Prevent Rails from even scheduling ActiveStorage::AnalyzeJob by overriding
# the method that schedules it.

Rails.application.config.after_initialize do
  ActiveStorage::Blob::Analyzable.module_eval do
    def analyze_later; end
  end
end
