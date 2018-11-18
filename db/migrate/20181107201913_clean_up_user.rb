class CleanUpUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :lat
    remove_column :users, :lng
    remove_column :users, :bio_html

    removals = User.where(activated_at: nil).where('created_at < ?', 4.week.ago)
    puts "removing #{removals.count} old non-activated users..."
    removals.delete_all

    puts "creating new profile db records for remaining #{User.count} users"
    User.find_each do |u|
      u.create_profile(bio: u.bio, city: u.city, country: u.country, website:u.website, twitter:u.twitter, user_agent:u.browser)
    end

    puts "removing old columns from user table"
    remove_column :users, :bio
    remove_column :users, :city
    remove_column :users, :country
    remove_column :users, :website
    remove_column :users, :twitter
    remove_column :users, :browser
  end
end
