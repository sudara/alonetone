class SanitizeProfileWebsite < ActiveRecord::Migration[6.0]
  def change
    Profile.where('website like "%http%" or website like "%https%"').find_each do |profile|
      profile.update_column(:website, profile.website.sub(/^https?\:\/\//, ''))
    end
  end
end
