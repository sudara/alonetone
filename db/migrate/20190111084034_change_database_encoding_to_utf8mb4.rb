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
    ActiveRecord::Base.connection.tables.each do |table_name|
      execute <<~SQL
        ALTER TABLE #{table_name}
        CONVERT TO CHARACTER SET #{encoding}
        COLLATE #{encoding}_unicode_ci
      SQL
    end
  end
end
