class CreateGreenfieldAttachedAssets < ActiveRecord::Migration
  def change
    create_table :greenfield_attached_assets do |t|
      t.integer :post_id
      t.attachment :mp3
      t.text :waveform
      t.timestamps
    end
  end
end
