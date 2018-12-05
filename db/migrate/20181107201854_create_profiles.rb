class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.references :user, type: :integer, foreign_key: true
      t.text :bio
      t.string :city
      t.string :country
      t.string :apple
      t.string :twitter
      t.string :spotify
      t.string :bandcamp
      t.string :instagram
      t.string :website
      t.string :user_agent

      t.datetime :updated_at
    end
  end
end
