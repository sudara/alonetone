class CreateSettings < ActiveRecord::Migration[6.0]

  SETTINGS = {
    display_listen_count: true,
    block_guest_comments: false,
    most_popular: true,
    increase_ego: false,
    email_comments: true,
    email_new_tracks: true
  }

  def change
    # temporary name until we drop the user.settings attribute
    create_table :new_settings do |t|
      t.references :user
      t.boolean :display_listen_count, default: true
      t.boolean :block_guest_comments, default: false
      t.boolean :most_popular, default: true
      t.boolean :increase_ego, default: false
      t.boolean :email_comments, default: true
      t.boolean :email_new_tracks, default: true

      t.timestamps
    end

    User.with_deleted.find_each do |user|
      # About 3k users have existing settings in an AR::store attribute, in the following format:
      # => {"display_listen_count"=>"true", "block_guest_comments"=>"false", "most_popular"=>"false", "increase_ego"=>"false", "email_comments"=>"true", "email_new_tracks"=>"true"}
      if user.settings
        attributes = user.settings.slice(*SETTINGS.keys) # get rid of settings we don't care about
        user.create_new_settings(attributes) # string attributes will be cast to boolean by rails
      else
        user.create_new_settings
      end
    end
  end
end
