class CreateReservedWords < ActiveRecord::Migration[7.0]
  def change
    create_table :reserved_words do |t|
      t.string :name, null: false
      t.text :details

      t.timestamps
    end

    add_index :reserved_words, :name, unique: true
  end
end
