class CleanUpUser < ActiveRecord::Migration[5.2]
  def change
    puts "removing old crufty user columns"
    # remove_column :users, :lat
    # remove_column :users, :lng
    # remove_column :users, :bio_html
    # remove_column :users, :activated_at

    removals = User.where('DATE(created_at) = DATE(updated_at)').where('assets_count = 0').where('created_at < ?', 4.week.ago)
    puts "removing #{removals.count} old users without tracks who didn't last a day..."

    Post.where(user_id: removals).delete_all
    Pic.where(picable_type: 'User').where(picable_id: removals).delete_all if Rails.env.production?
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
