class SoftDeleteAllSpamAssets < ActiveRecord::Migration[6.0]
  def change
    assets_count = Asset.where(is_spam: true).count
    puts "Assets found #{assets_count} assets"
    Asset.where(is_spam: true).find_each do |asset|
      AssetCommand.new(asset).soft_delete_with_relations
    end
  end
end
