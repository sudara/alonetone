class AddAccountRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :account_requests do |t|
      t.string :email
      t.string :login
      t.integer :entity_type
      t.integer :status, default: 0
      t.text :details
      t.timestamps
    end
  end
end
