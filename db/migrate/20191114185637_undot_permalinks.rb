# frozen_string_literal: true

class UndotPermalinks < ActiveRecord::Migration[6.0]
  def up
    Asset.select(:id, :permalink).where("permalink LIKE '%.%'").each do |asset|
      # Replace a dot with a dash and multiple dashes with one dash.
      permalink = asset.permalink.tr('.', '-').gsub(%r{-+}, '-')
      asset.update_columns(permalink: permalink, updated_at: Time.zone.now)
    end
  end

  def down; end
end
