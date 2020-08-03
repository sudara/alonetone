class AddYoutubeToProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :youtube, :string
  end
end
