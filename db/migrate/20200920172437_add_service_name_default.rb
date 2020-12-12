class AddServiceNameDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:active_storage_blobs, :service_name, "filesystem")
  end
end
