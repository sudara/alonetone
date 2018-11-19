class AddIsSpamToTracks < ActiveRecord::Migration[5.2]
  def change
    add_column :assets, :is_spam, :boolean, default: false
  end
end
