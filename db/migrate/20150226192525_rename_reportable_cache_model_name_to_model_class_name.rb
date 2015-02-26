class RenameReportableCacheModelNameToModelClassName < ActiveRecord::Migration
  def change
    rename_column :reportable_cache, :model_name, :model_class_name
  end
end
