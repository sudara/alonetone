# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170819153513) do

  create_table "assets", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "mp3_content_type"
    t.string "mp3_file_name"
    t.integer "mp3_file_size"
    t.datetime "created_at"
    t.string "title"
    t.integer "thumbnails_count", default: 0
    t.integer "user_id"
    t.integer "length"
    t.string "album"
    t.string "permalink"
    t.integer "samplerate"
    t.integer "bitrate"
    t.string "genre"
    t.string "artist"
    t.integer "listens_count", default: 0
    t.text "description", limit: 16777215
    t.text "credits", limit: 16777215
    t.string "youtube_embed"
    t.float "hotness", limit: 24
    t.integer "favorites_count", default: 0
    t.text "lyrics", limit: 16777215
    t.text "description_html", limit: 16777215
    t.float "listens_per_week", limit: 24
    t.integer "comments_count", default: 0
    t.datetime "updated_at"
    t.text "waveform", limit: 4294967295
    t.boolean "private", default: false, null: false
    t.index ["hotness"], name: "index_assets_on_hotness"
    t.index ["permalink"], name: "index_assets_on_permalink"
    t.index ["updated_at"], name: "index_assets_on_updated_at"
    t.index ["user_id", "listens_per_week"], name: "index_assets_on_user_id_and_listens_per_day"
    t.index ["user_id"], name: "index_assets_on_user_id"
  end

  create_table "audio_features", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "asset_id"
    t.text "waveform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_audio_features_on_asset_id"
  end

  create_table "comments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "commentable_type"
    t.integer "commentable_id"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "commenter_id"
    t.integer "user_id"
    t.string "remote_ip"
    t.string "user_agent"
    t.string "referrer"
    t.boolean "is_spam", default: false
    t.boolean "private", default: false
    t.text "body_html"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commenter_id"], name: "index_comments_on_commenter_id"
    t.index ["created_at"], name: "index_comments_on_created_at"
    t.index ["is_spam"], name: "index_comments_on_is_spam"
  end

  create_table "featured_tracks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "position", default: 1
    t.integer "feature_id"
    t.integer "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "featured_user_id"
    t.integer "writer_id"
    t.integer "views_count", default: 0
    t.text "body"
    t.text "teaser_text"
    t.boolean "published", default: false
    t.boolean "published_at"
    t.boolean "datetime"
    t.string "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "follower_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["follower_id"], name: "index_followings_on_follower_id"
    t.index ["user_id"], name: "index_followings_on_user_id"
  end

  create_table "forums", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "site_id"
    t.string "name"
    t.string "description"
    t.integer "topics_count", default: 0
    t.integer "posts_count", default: 0
    t.integer "position", default: 1
    t.text "description_html"
    t.string "state", default: "public"
    t.string "permalink"
    t.index ["permalink"], name: "index_forums_on_permalink"
    t.index ["position"], name: "index_forums_on_position"
  end

  create_table "greenfield_attached_assets", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "post_id"
    t.string "mp3_file_name"
    t.string "mp3_content_type"
    t.integer "mp3_file_size"
    t.datetime "mp3_updated_at"
    t.text "waveform", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "length"
  end

  create_table "greenfield_playlist_downloads", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title", null: false
    t.integer "playlist_id", null: false
    t.string "s3_path", null: false
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer "serves", default: 0, null: false
  end

  create_table "greenfield_posts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "asset_id"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "permalink"
  end

  create_table "listens", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "listener_id"
    t.integer "track_owner_id"
    t.string "source"
    t.string "ip"
    t.string "user_agent"
    t.string "city"
    t.string "country"
    t.index ["asset_id"], name: "index_listens_on_asset_id"
    t.index ["created_at"], name: "index_listens_on_created_at"
    t.index ["listener_id"], name: "index_listens_on_listener_id"
    t.index ["track_owner_id", "created_at"], name: "index_listens_on_track_owner_id_and_created_at"
    t.index ["track_owner_id"], name: "index_listens_on_track_owner_id"
  end

  create_table "memberships", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.boolean "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pics", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "pic_file_size"
    t.string "pic_content_type"
    t.string "pic_file_name"
    t.integer "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "picable_type"
    t.integer "picable_id"
    t.index ["picable_id", "picable_type"], name: "index_pics_on_picable_id_and_picable_type"
  end

  create_table "playlists", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "title"
    t.text "description", limit: 16777215
    t.string "image"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "pic_id"
    t.string "permalink"
    t.integer "tracks_count", default: 0
    t.boolean "is_mix"
    t.boolean "private"
    t.boolean "is_favorite", default: false
    t.string "year"
    t.integer "position", default: 1
    t.string "link1"
    t.string "link2"
    t.string "link3"
    t.text "credits", limit: 16777215
    t.boolean "has_details", default: false
    t.string "theme"
    t.index ["permalink"], name: "index_playlists_on_permalink"
    t.index ["position"], name: "index_playlists_on_position"
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "posts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "topic_id"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "forum_id"
    t.text "body_html"
    t.boolean "is_spam", default: false
    t.float "spaminess", limit: 24
    t.string "signature"
    t.index ["is_spam"], name: "index_posts_on_is_spam"
  end

  create_table "topics", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "forum_id"
    t.integer "user_id"
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "hits", default: 0
    t.integer "sticky", default: 0
    t.integer "posts_count", default: 0
    t.boolean "locked", default: false
    t.integer "last_post_id"
    t.datetime "last_updated_at"
    t.integer "last_user_id"
    t.integer "site_id"
    t.string "permalink"
    t.boolean "spam", default: false
    t.float "spaminess", limit: 24
    t.string "signature"
    t.index ["forum_id", "permalink"], name: "index_topics_on_forum_id_and_permalink"
    t.index ["last_updated_at", "forum_id"], name: "index_topics_on_forum_id_and_last_updated_at"
    t.index ["sticky", "last_updated_at", "forum_id"], name: "index_topics_on_sticky_and_last_updated_at"
  end

  create_table "tracks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "playlist_id"
    t.integer "asset_id"
    t.integer "position", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_favorite", default: false
    t.integer "user_id"
    t.index ["asset_id"], name: "index_tracks_on_asset_id"
    t.index ["is_favorite"], name: "index_tracks_on_is_favorite"
    t.index ["playlist_id"], name: "index_tracks_on_playlist_id"
    t.index ["user_id"], name: "index_tracks_on_user_id"
  end

  create_table "updates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "revision"
    t.text "content_html"
    t.string "permalink"
  end

  create_table "user_reports", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.string "category"
    t.text "description"
    t.string "params"
    t.string "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "spam", default: false
    t.float "spaminess", limit: 24
    t.string "signature"
    t.text "description_html"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "login", limit: 40
    t.string "email", limit: 100
    t.string "salt", limit: 128, default: "", null: false
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "admin", default: false
    t.datetime "last_login_at"
    t.string "crypted_password", limit: 128, default: "", null: false
    t.integer "assets_count", default: 0, null: false
    t.string "display_name"
    t.integer "playlists_count", default: 0, null: false
    t.string "website"
    t.text "bio", limit: 16777215
    t.integer "listens_count", default: 0
    t.string "itunes"
    t.integer "comments_count", default: 0
    t.string "last_login_ip"
    t.string "country"
    t.string "city"
    t.text "settings", limit: 16777215
    t.float "lat", limit: 24
    t.float "lng", limit: 24
    t.text "bio_html", limit: 16777215
    t.integer "posts_count", default: 0
    t.boolean "moderator", default: false
    t.string "browser"
    t.string "twitter"
    t.integer "followers_count", default: 0
    t.integer "login_count", default: 0, null: false
    t.datetime "current_login_at"
    t.string "current_login_ip"
    t.string "persistence_token"
    t.string "perishable_token"
    t.datetime "last_request_at"
    t.integer "bandwidth_used", default: 0
    t.boolean "greenfield_enabled", default: false
    t.boolean "white_theme_enabled", default: false
    t.index ["updated_at"], name: "index_users_on_updated_at"
  end

end
