class AddLastUploadedAtToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :last_uploaded_at, :datetime

    say_with_time 'Backfilling users.last_uploaded_at' do
      execute <<~SQL.squish
        UPDATE users
        INNER JOIN (
          SELECT user_id, MAX(created_at) AS last_uploaded_at
          FROM assets
          WHERE deleted_at IS NULL AND user_id IS NOT NULL
          GROUP BY user_id
        ) latest_assets ON latest_assets.user_id = users.id
        SET users.last_uploaded_at = latest_assets.last_uploaded_at
      SQL
    end

    add_index :users, %i[deleted_at last_uploaded_at],
      name: :index_users_on_deleted_at_and_last_uploaded_at,
      algorithm: :inplace
  end

  def down
    remove_index :users, name: :index_users_on_deleted_at_and_last_uploaded_at
    remove_column :users, :last_uploaded_at
  end
end
