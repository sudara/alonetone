class AddCityAndCountryToListen < ActiveRecord::Migration[5.1]
  def change
    add_column :listens, :city, :string
    add_column :listens, :country, :string
  end
end
