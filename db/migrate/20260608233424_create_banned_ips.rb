class CreateBannedIps < ActiveRecord::Migration[8.1]
  def change
    create_table :banned_ips do |t|
      t.string :ip, null: false
      t.bigint :banned_by_id
      t.timestamps
    end
    add_index :banned_ips, :ip, unique: true
  end
end
