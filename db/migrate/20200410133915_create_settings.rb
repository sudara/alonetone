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
      t.add_reference :user, foreign_key: true
      t.boolean :display_listen_count, default: true
      t.boolean :block_guest_comments, default: false
      t.boolean :most_popular, default: true
      t.boolean :increase_ego, default: false
      t.boolean :email_comments, default: true
      t.boolean :email_new_tracks, default: true

      t.timestamps
    end

    User.with_deleted.find_each do |user|
      if user.settings # About 3k users have existing settings
        attributes = user.settings.slice(*SETTINGS.keys) # get rid of settings we don't care about
        attributes.each do |key, value|
          attributes[key] = ActiveModel::Type::Boolean.new.cast(value) # we have booleans stored as strings right now
        end
        user.new_settings.create!(attributes)
      else
        user.new_settings.create!
      end
    end

  end
end
