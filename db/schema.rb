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

ActiveRecord::Schema.define(version: 20161227061031) do

  create_table "assets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "mp3_content_type"
    t.string   "mp3_file_name"
    t.integer  "mp3_file_size"
    t.integer  "parent_id"
    t.integer  "site_id"
    t.datetime "created_at"
    t.string   "title"
    t.integer  "thumbnails_count",                  default: 0
    t.integer  "user_id"
    t.integer  "length"
    t.string   "album"
    t.string   "permalink"
    t.integer  "samplerate"
    t.integer  "bitrate"
    t.string   "genre"
    t.string   "artist"
    t.integer  "listens_count",                     default: 0
    t.text     "description",      limit: 65535
    t.text     "credits",          limit: 65535
    t.string   "youtube_embed"
    t.float    "hotness",          limit: 24
    t.integer  "favorites_count",                   default: 0
    t.text     "lyrics",           limit: 65535
    t.text     "description_html", limit: 65535
    t.float    "listens_per_week", limit: 24
    t.integer  "comments_count",                    default: 0
    t.datetime "updated_at"
    t.text     "waveform",         limit: 16777215
    t.boolean  "private",                           default: false, null: false
    t.index ["hotness"], name: "index_assets_on_hotness", using: :btree
    t.index ["permalink"], name: "index_assets_on_permalink", using: :btree
    t.index ["user_id", "listens_per_week"], name: "index_assets_on_user_id_and_listens_per_day", using: :btree
    t.index ["user_id"], name: "index_assets_on_user_id", using: :btree
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.text     "body",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commenter_id"
    t.integer  "user_id"
    t.string   "remote_ip"
    t.string   "user_agent",       limit: 511
    t.string   "referrer"
    t.boolean  "is_spam",                        default: false
    t.boolean  "private",                        default: false
    t.text     "body_html",        limit: 65535
    t.index ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
    t.index ["commenter_id"], name: "index_comments_on_commenter_id", using: :btree
    t.index ["created_at"], name: "index_comments_on_created_at", using: :btree
    t.index ["is_spam"], name: "index_comments_on_is_spam", using: :btree
  end

  create_table "facebook_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "fb_user_id"
    t.index ["fb_user_id"], name: "index_facebook_accounts_on_fb_user_id", using: :btree
  end

  create_table "facebook_addables", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "profile_chunk_type"
    t.integer  "profile_chunk_id"
    t.integer  "facebook_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "featured_tracks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "position",   default: 1
    t.integer  "feature_id"
    t.integer  "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "featured_user_id"
    t.integer  "writer_id"
    t.integer  "views_count",                    default: 0
    t.text     "body",             limit: 65535
    t.text     "teaser_text",      limit: 65535
    t.boolean  "published",                      default: false
    t.boolean  "published_at"
    t.boolean  "datetime"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id"
    t.integer  "follower_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["follower_id"], name: "index_followings_on_follower_id", using: :btree
    t.index ["user_id"], name: "index_followings_on_user_id", using: :btree
  end

  create_table "forums", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "site_id"
    t.string  "name"
    t.string  "description"
    t.integer "topics_count",                   default: 0
    t.integer "posts_count",                    default: 0
    t.integer "position",                       default: 1
    t.text    "description_html", limit: 65535
    t.string  "state",                          default: "public"
    t.string  "permalink"
    t.index ["permalink"], name: "index_forums_on_permalink", using: :btree
    t.index ["position"], name: "index_forums_on_position", using: :btree
  end

  create_table "greenfield_attached_assets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "post_id"
    t.string   "mp3_file_name"
    t.string   "mp3_content_type"
    t.integer  "mp3_file_size"
    t.datetime "mp3_updated_at"
    t.text     "waveform",         limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length"
  end

  create_table "greenfield_playlist_downloads", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "title",                               null: false
    t.integer  "playlist_id",                         null: false
    t.string   "s3_path",                             null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "serves",                  default: 0, null: false
  end

  create_table "greenfield_posts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "asset_id"
    t.text     "body",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
  end

  create_table "listens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "listener_id"
    t.integer  "track_owner_id"
    t.string   "source"
    t.string   "ip"
    t.string   "user_agent",     limit: 511
    t.index ["asset_id"], name: "index_listens_on_asset_id", using: :btree
    t.index ["created_at"], name: "index_listens_on_created_at", using: :btree
    t.index ["listener_id"], name: "index_listens_on_listener_id", using: :btree
    t.index ["track_owner_id", "created_at"], name: "index_listens_on_track_owner_id_and_created_at", using: :btree
    t.index ["track_owner_id"], name: "index_listens_on_track_owner_id", using: :btree
  end

  create_table "logged_exceptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "message",         limit: 65535
    t.text     "backtrace",       limit: 65535
    t.text     "environment",     limit: 65535
    t.text     "request",         limit: 65535
    t.datetime "created_at"
  end

  create_table "memberships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pics", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "pic_file_size"
    t.string   "pic_content_type"
    t.string   "pic_file_name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picable_type"
    t.integer  "picable_id"
    t.index ["picable_id", "picable_type"], name: "index_pics_on_picable_id_and_picable_type", using: :btree
  end

  create_table "playlists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "title"
    t.text     "description",  limit: 65535
    t.string   "image"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pic_id"
    t.string   "permalink"
    t.integer  "tracks_count",               default: 0
    t.boolean  "is_mix"
    t.boolean  "private"
    t.boolean  "is_favorite",                default: false
    t.string   "year"
    t.integer  "position",                   default: 1
    t.string   "link1"
    t.string   "link2"
    t.string   "link3"
    t.text     "credits",      limit: 65535
    t.boolean  "has_details",                default: false
    t.string   "theme"
    t.index ["permalink"], name: "index_playlists_on_permalink", using: :btree
    t.index ["position"], name: "index_playlists_on_position", using: :btree
    t.index ["user_id"], name: "index_playlists_on_user_id", using: :btree
  end

  create_table "posts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.text     "body",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.text     "body_html",  limit: 65535
    t.boolean  "is_spam",                  default: false
    t.float    "spaminess",  limit: 24
    t.string   "signature"
    t.index ["is_spam"], name: "index_posts_on_is_spam", using: :btree
  end

  create_table "reportable_cache", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "model_class_name", limit: 100,               null: false
    t.string   "report_name",      limit: 100,               null: false
    t.string   "grouping",         limit: 10,                null: false
    t.string   "aggregation",      limit: 10,                null: false
    t.string   "conditions",       limit: 100,               null: false
    t.float    "value",            limit: 24,  default: 0.0, null: false
    t.datetime "reporting_period",                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["model_class_name", "report_name", "grouping", "aggregation", "conditions", "reporting_period"], name: "name_model_grouping_aggregation_period", unique: true, using: :btree
    t.index ["model_class_name", "report_name", "grouping", "aggregation", "conditions"], name: "name_model_grouping_agregation", using: :btree
  end

  create_table "topics", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hits",                       default: 0
    t.integer  "sticky",                     default: 0
    t.integer  "posts_count",                default: 0
    t.boolean  "locked",                     default: false
    t.integer  "last_post_id"
    t.datetime "last_updated_at"
    t.integer  "last_user_id"
    t.integer  "site_id"
    t.string   "permalink"
    t.boolean  "spam",                       default: false
    t.float    "spaminess",       limit: 24
    t.string   "signature"
    t.index ["forum_id", "permalink"], name: "index_topics_on_forum_id_and_permalink", using: :btree
    t.index ["last_updated_at", "forum_id"], name: "index_topics_on_forum_id_and_last_updated_at", using: :btree
    t.index ["sticky", "last_updated_at", "forum_id"], name: "index_topics_on_sticky_and_last_updated_at", using: :btree
  end

  create_table "tracks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "playlist_id"
    t.integer  "asset_id"
    t.integer  "position",    default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_favorite", default: false
    t.integer  "user_id"
    t.index ["asset_id"], name: "index_tracks_on_asset_id", using: :btree
    t.index ["is_favorite"], name: "index_tracks_on_is_favorite", using: :btree
    t.index ["playlist_id"], name: "index_tracks_on_playlist_id", using: :btree
    t.index ["user_id"], name: "index_tracks_on_user_id", using: :btree
  end

  create_table "updates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "title"
    t.text     "content",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "revision"
    t.text     "content_html", limit: 65535
    t.string   "permalink"
  end

  create_table "user_reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id"
    t.string   "category"
    t.text     "description",      limit: 65535
    t.string   "params"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "spam",                           default: false
    t.float    "spaminess",        limit: 24
    t.string   "signature"
    t.text     "description_html", limit: 65535
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "login",               limit: 40
    t.string   "email",               limit: 100
    t.string   "salt",                limit: 128,   default: "",    null: false
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "token"
    t.datetime "token_expires_at"
    t.boolean  "admin",                             default: false
    t.datetime "last_login_at"
    t.string   "crypted_password",    limit: 128,   default: "",    null: false
    t.integer  "assets_count",                      default: 0,     null: false
    t.string   "display_name"
    t.string   "identity_url"
    t.integer  "pic_id"
    t.integer  "playlists_count",                   default: 0,     null: false
    t.string   "website"
    t.text     "bio",                 limit: 65535
    t.integer  "listens_count",                     default: 0
    t.string   "itunes"
    t.integer  "comments_count",                    default: 0
    t.string   "last_login_ip"
    t.string   "country"
    t.string   "city"
    t.text     "extended_bio",        limit: 65535
    t.string   "myspace"
    t.text     "settings",            limit: 65535
    t.float    "lat",                 limit: 24
    t.float    "lng",                 limit: 24
    t.text     "bio_html",            limit: 65535
    t.integer  "posts_count",                       default: 0
    t.boolean  "moderator",                         default: false
    t.datetime "last_session_at"
    t.string   "browser"
    t.string   "twitter"
    t.integer  "followers_count",                   default: 0
    t.string   "remember_token"
    t.string   "remember_created_at"
    t.integer  "login_count",                       default: 0,     null: false
    t.datetime "current_login_at"
    t.string   "current_login_ip"
    t.string   "persistence_token"
    t.string   "perishable_token"
    t.datetime "last_request_at"
    t.integer  "bandwidth_used",                    default: 0
    t.boolean  "greenfield_enabled",                default: false
  end

end
