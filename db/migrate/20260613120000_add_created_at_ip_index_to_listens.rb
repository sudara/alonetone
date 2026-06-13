class AddCreatedAtIpIndexToListens < ActiveRecord::Migration[8.1]
  def change
    add_index :listens, %i[created_at ip], algorithm: :inplace
    add_index :listens, %i[asset_id ip deleted_at created_at],
      name: :index_listens_on_asset_ip_deleted_created,
      algorithm: :inplace
    add_index :listens, %i[asset_id deleted_at listener_id created_at],
      name: :index_listens_on_asset_deleted_listener_created,
      algorithm: :inplace
  end
end
