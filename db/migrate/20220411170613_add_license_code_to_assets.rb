class AddLicenseCodeToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :license_code, :string, default: 'all-rights-reserved'
  end
end
