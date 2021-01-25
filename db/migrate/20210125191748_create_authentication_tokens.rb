class CreateAuthenticationTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :authentication_tokens do |t|
      t.references :user
      t.string :token, null: false
      t.datetime :valid_until, precision: 6, null: false
      t.datetime :created_at, precision: 6, null: false
    end

    add_index :authentication_tokens, :token, unique: true
  end
end
