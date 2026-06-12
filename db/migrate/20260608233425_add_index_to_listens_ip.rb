class AddIndexToListensIp < ActiveRecord::Migration[8.1]
  def change
    # listens is multi-million-row and 15 years old; INPLACE/LOCK=NONE keeps reads+writes flowing.
    add_index :listens, :ip, algorithm: :inplace
  end
end
