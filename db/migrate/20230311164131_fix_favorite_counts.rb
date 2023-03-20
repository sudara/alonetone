class FixFavoriteCounts < ActiveRecord::Migration[7.0]
  def change
    execute <<-SQL
      UPDATE assets A
      INNER JOIN (SELECT asset_id, COUNT(*) idcount FROM tracks 
                  WHERE is_favorite = true GROUP BY asset_id) as T
      ON T.asset_id = A.id
      SET A.favorites_count = T.idcount
    SQL
  end
end
