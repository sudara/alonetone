# frozen_string_literal: true

class ChangeDatabaseEncodingToUtf8mb4 < ActiveRecord::Migration[5.2]
  def up
    change_encoding('utf8mb4')
  end

  def down
    change_encoding('utf8')
  end

  private

  def change_encoding(encoding)
    execute <<~SQL
      ALTER DATABASE #{ActiveRecord::Base.connection.current_database}
      CHARACTER SET = #{encoding}
      COLLATE #{encoding}_unicode_ci
    SQL
    remove_indices
    ActiveRecord::Base.connection.tables.each do |table_name|
      execute <<~SQL
        ALTER TABLE #{table_name}
        CONVERT TO CHARACTER SET #{encoding}
        COLLATE #{encoding}_unicode_ci
      SQL
    end
    create_indices
  end

  def remove_indices
    remove_index(:active_storage_attachments, name: :index_active_storage_attachments_uniqueness)
    remove_index(:active_storage_blobs, name: :index_active_storage_blobs_on_key)
    remove_index(:ar_internal_metadata, name: 'PRIMARY')
    remove_index(:assets, name: :index_assets_on_permalink)
    remove_index(:comments, name: :index_comments_on_commentable_type_and_is_spam_and_private)
    remove_index(:comments, name: :by_user_id_type_spam_private)
    remove_index(:forums, name: :index_forums_on_permalink)
    remove_index(:pics, name: :index_pics_on_picable_id_and_picable_type)
    remove_index(:playlists, name: :index_playlists_on_permalink)
    remove_index(:schema_migrations, name: 'PRIMARY')
    remove_index(:topics, name: :index_topics_on_forum_id_and_permalink)
  end

  def create_indices
    add_index(
      :active_storage_attachments,
      %i[record_type record_id name blob_id],
      name: 'index_active_storage_attachments_uniqueness',
      unique: true,
      length: { record_type: 191, name: 191 }
    )
    add_index(
      :active_storage_blobs,
      :key,
      name: 'index_active_storage_blobs_on_key',
      unique: true,
      length: { key: 191 }
    )
    execute("ALTER TABLE ar_internal_metadata MODIFY `key` VARCHAR(191)")
    execute("ALTER TABLE ar_internal_metadata ADD PRIMARY KEY(`key`)")
    add_index(:assets, :permalink, length: 191)
    add_index(:comments, %i[commentable_type is_spam private], length: { commentable_type: 191 })
    add_index(
      :comments, %i[user_id commentable_type is_spam private],
      name: 'by_user_id_type_spam_private',
      length: { commentable_type: 191 }
    )
    add_index(:forums, :permalink, length: 191)
    add_index(:pics, %i[picable_id picable_type], length: { picable_type: 191})
    add_index(:playlists, :permalink, length: 191)
    execute("ALTER TABLE schema_migrations MODIFY `version` VARCHAR(191)")
    execute("ALTER TABLE schema_migrations ADD PRIMARY KEY(`version`)")
    add_index(:topics, %i[forum_id permalink], length: { permalink: 191 })
  end
end
