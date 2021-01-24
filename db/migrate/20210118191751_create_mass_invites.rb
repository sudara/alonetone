class CreateMassInvites < ActiveRecord::Migration[6.1]
  def change
    create_table :mass_invites do |t|
      t.text :name, null: false
      t.string :token, null: false
      t.boolean :archived, default: false, null: false
      t.integer :users_count, default: 0, null: false

      t.timestamps
    end

    add_index :mass_invites, :token, unique: true
  end
end
