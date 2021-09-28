class CreatePatrons < ActiveRecord::Migration[6.1]
  def change
    create_table :patrons do |t|
      t.references :user, null: false, foreign_key: true, index: true, type: :int

      t.datetime "created_at"
    end
  end
end
