# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160204165441) do

  create_table "assets", force: :cascade do |t|
    t.string   "mp3_content_type", limit: 255
    t.string   "mp3_file_name",    limit: 255
    t.integer  "mp3_file_size",    limit: 4
    t.integer  "parent_id",        limit: 4
    t.integer  "site_id",          limit: 4
    t.datetime "created_at"
    t.string   "title",            limit: 255
    t.integer  "thumbnails_count", limit: 4,        default: 0
    t.integer  "user_id",          limit: 4
    t.integer  "length",           limit: 4
    t.string   "album",            limit: 255
    t.string   "permalink",        limit: 255
    t.integer  "samplerate",       limit: 4
    t.integer  "bitrate",          limit: 4
    t.string   "genre",            limit: 255
    t.string   "artist",           limit: 255
    t.integer  "listens_count",    limit: 4,        default: 0
    t.text     "description",      limit: 65535
    t.text     "credits",          limit: 65535
    t.string   "youtube_embed",    limit: 255
    t.float    "hotness",          limit: 24
    t.integer  "favorites_count",  limit: 4,        default: 0
    t.text     "lyrics",           limit: 65535
    t.text     "description_html", limit: 65535
    t.float    "listens_per_week", limit: 24
    t.integer  "comments_count",   limit: 4,        default: 0
    t.datetime "updated_at"
    t.text     "waveform",         limit: 16777215
    t.boolean  "private",          limit: 1,        default: false, null: false
  end

  add_index "assets", ["hotness"], name: "index_assets_on_hotness", using: :btree
  add_index "assets", ["permalink"], name: "index_assets_on_permalink", using: :btree
  add_index "assets", ["user_id", "listens_per_week"], name: "index_assets_on_user_id_and_listens_per_day", using: :btree
  add_index "assets", ["user_id"], name: "index_assets_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "commentable_type", limit: 255
    t.integer  "commentable_id",   limit: 4
    t.text     "body",             limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commenter_id",     limit: 4
    t.integer  "user_id",          limit: 4
    t.string   "remote_ip",        limit: 255
    t.string   "user_agent",       limit: 255
    t.string   "referrer",         limit: 255
    t.boolean  "is_spam",          limit: 1,     default: false
    t.boolean  "private",          limit: 1,     default: false
    t.text     "body_html",        limit: 65535
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commenter_id"], name: "index_comments_on_commenter_id", using: :btree
  add_index "comments", ["created_at"], name: "index_comments_on_created_at", using: :btree
  add_index "comments", ["is_spam"], name: "index_comments_on_is_spam", using: :btree

  create_table "facebook_accounts", force: :cascade do |t|
    t.integer "fb_user_id", limit: 8
  end

  add_index "facebook_accounts", ["fb_user_id"], name: "index_facebook_accounts_on_fb_user_id", using: :btree

  create_table "facebook_addables", force: :cascade do |t|
    t.string   "profile_chunk_type",  limit: 255
    t.integer  "profile_chunk_id",    limit: 4
    t.integer  "facebook_account_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "featured_tracks", force: :cascade do |t|
    t.integer  "position",   limit: 4, default: 1
    t.integer  "feature_id", limit: 4
    t.integer  "asset_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features", force: :cascade do |t|
    t.integer  "featured_user_id", limit: 4
    t.integer  "writer_id",        limit: 4
    t.integer  "views_count",      limit: 4,     default: 0
    t.text     "body",             limit: 65535
    t.text     "teaser_text",      limit: 65535
    t.boolean  "published",        limit: 1,     default: false
    t.boolean  "published_at",     limit: 1
    t.boolean  "datetime",         limit: 1
    t.string   "permalink",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followings", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "follower_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followings", ["follower_id"], name: "index_followings_on_follower_id", using: :btree
  add_index "followings", ["user_id"], name: "index_followings_on_user_id", using: :btree

  create_table "forums", force: :cascade do |t|
    t.integer "site_id",          limit: 4
    t.string  "name",             limit: 255
    t.string  "description",      limit: 255
    t.integer "topics_count",     limit: 4,     default: 0
    t.integer "posts_count",      limit: 4,     default: 0
    t.integer "position",         limit: 4,     default: 1
    t.text    "description_html", limit: 65535
    t.string  "state",            limit: 255,   default: "public"
    t.string  "permalink",        limit: 255
  end

  add_index "forums", ["permalink"], name: "index_forums_on_permalink", using: :btree
  add_index "forums", ["position"], name: "index_forums_on_position", using: :btree

  create_table "greenfield_attached_assets", force: :cascade do |t|
    t.integer  "post_id",          limit: 4
    t.string   "mp3_file_name",    limit: 255
    t.string   "mp3_content_type", limit: 255
    t.integer  "mp3_file_size",    limit: 4
    t.datetime "mp3_updated_at"
    t.text     "waveform",         limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length",           limit: 4
  end

  create_table "greenfield_posts", force: :cascade do |t|
    t.integer  "asset_id",   limit: 4
    t.text     "body",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink",   limit: 255
  end

  create_table "listens", force: :cascade do |t|
    t.integer  "asset_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "listener_id",    limit: 4
    t.integer  "track_owner_id", limit: 4
    t.string   "source",         limit: 255
    t.string   "ip",             limit: 255
    t.string   "user_agent",     limit: 255
  end

  add_index "listens", ["asset_id"], name: "index_listens_on_asset_id", using: :btree
  add_index "listens", ["created_at"], name: "index_listens_on_created_at", using: :btree
  add_index "listens", ["listener_id"], name: "index_listens_on_listener_id", using: :btree
  add_index "listens", ["track_owner_id", "created_at"], name: "index_listens_on_track_owner_id_and_created_at", using: :btree
  add_index "listens", ["track_owner_id"], name: "index_listens_on_track_owner_id", using: :btree

  create_table "logged_exceptions", force: :cascade do |t|
    t.string   "exception_class", limit: 255
    t.string   "controller_name", limit: 255
    t.string   "action_name",     limit: 255
    t.text     "message",         limit: 65535
    t.text     "backtrace",       limit: 65535
    t.text     "environment",     limit: 65535
    t.text     "request",         limit: 65535
    t.datetime "created_at"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "group_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.boolean  "admin",      limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pics", force: :cascade do |t|
    t.integer  "pic_file_size",    limit: 4
    t.string   "pic_content_type", limit: 255
    t.string   "pic_file_name",    limit: 255
    t.integer  "parent_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picable_type",     limit: 255
    t.integer  "picable_id",       limit: 4
  end

  add_index "pics", ["picable_id", "picable_type"], name: "index_pics_on_picable_id_and_picable_type", using: :btree

  create_table "playlists", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.text     "description",  limit: 65535
    t.string   "image",        limit: 255
    t.integer  "user_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pic_id",       limit: 4
    t.string   "permalink",    limit: 255
    t.integer  "tracks_count", limit: 4,     default: 0
    t.boolean  "is_mix",       limit: 1
    t.boolean  "private",      limit: 1
    t.boolean  "is_favorite",  limit: 1,     default: false
    t.string   "year",         limit: 255
    t.integer  "position",     limit: 4,     default: 1
    t.string   "link1",        limit: 255
    t.string   "link2",        limit: 255
    t.string   "link3",        limit: 255
  end

  add_index "playlists", ["permalink"], name: "index_playlists_on_permalink", using: :btree
  add_index "playlists", ["position"], name: "index_playlists_on_position", using: :btree
  add_index "playlists", ["user_id"], name: "index_playlists_on_user_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "topic_id",   limit: 4
    t.text     "body",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id",   limit: 4
    t.text     "body_html",  limit: 65535
    t.boolean  "is_spam",    limit: 1,     default: false
    t.float    "spaminess",  limit: 24
    t.string   "signature",  limit: 255
  end

  add_index "posts", ["is_spam"], name: "index_posts_on_is_spam", using: :btree

  create_table "reportable_cache", force: :cascade do |t|
    t.string   "model_class_name", limit: 100,               null: false
    t.string   "report_name",      limit: 100,               null: false
    t.string   "grouping",         limit: 10,                null: false
    t.string   "aggregation",      limit: 10,                null: false
    t.string   "conditions",       limit: 100,               null: false
    t.float    "value",            limit: 24,  default: 0.0, null: false
    t.datetime "reporting_period",                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reportable_cache", ["model_class_name", "report_name", "grouping", "aggregation", "conditions", "reporting_period"], name: "name_model_grouping_aggregation_period", unique: true, using: :btree
  add_index "reportable_cache", ["model_class_name", "report_name", "grouping", "aggregation", "conditions"], name: "name_model_grouping_agregation", using: :btree

  create_table "source_files", force: :cascade do |t|
    t.string   "content_type",    limit: 255
    t.string   "filename",        limit: 255
    t.integer  "size",            limit: 8
    t.integer  "user_id",         limit: 4
    t.integer  "downloads_count", limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", force: :cascade do |t|
    t.integer  "forum_id",        limit: 4
    t.integer  "user_id",         limit: 4
    t.string   "title",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hits",            limit: 4,   default: 0
    t.integer  "sticky",          limit: 4,   default: 0
    t.integer  "posts_count",     limit: 4,   default: 0
    t.boolean  "locked",          limit: 1,   default: false
    t.integer  "last_post_id",    limit: 4
    t.datetime "last_updated_at"
    t.integer  "last_user_id",    limit: 4
    t.integer  "site_id",         limit: 4
    t.string   "permalink",       limit: 255
    t.boolean  "spam",            limit: 1,   default: false
    t.float    "spaminess",       limit: 24
    t.string   "signature",       limit: 255
  end

  add_index "topics", ["forum_id", "permalink"], name: "index_topics_on_forum_id_and_permalink", using: :btree
  add_index "topics", ["last_updated_at", "forum_id"], name: "index_topics_on_forum_id_and_last_updated_at", using: :btree
  add_index "topics", ["sticky", "last_updated_at", "forum_id"], name: "index_topics_on_sticky_and_last_updated_at", using: :btree

  create_table "tracks", force: :cascade do |t|
    t.integer  "playlist_id", limit: 4
    t.integer  "asset_id",    limit: 4
    t.integer  "position",    limit: 4, default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_favorite", limit: 1, default: false
    t.integer  "user_id",     limit: 4
  end

  add_index "tracks", ["asset_id"], name: "index_tracks_on_asset_id", using: :btree
  add_index "tracks", ["is_favorite"], name: "index_tracks_on_is_favorite", using: :btree
  add_index "tracks", ["playlist_id"], name: "index_tracks_on_playlist_id", using: :btree
  add_index "tracks", ["user_id"], name: "index_tracks_on_user_id", using: :btree

  create_table "updates", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.text     "content",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "revision",     limit: 4
    t.text     "content_html", limit: 65535
    t.string   "permalink",    limit: 255
  end

  create_table "user_reports", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.string   "category",         limit: 255
    t.text     "description",      limit: 65535
    t.string   "params",           limit: 255
    t.string   "path",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "spam",             limit: 1,     default: false
    t.float    "spaminess",        limit: 24
    t.string   "signature",        limit: 255
    t.text     "description_html", limit: 65535
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",               limit: 40
    t.string   "email",               limit: 100
    t.string   "salt",                limit: 128,   default: "",    null: false
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "token",               limit: 255
    t.datetime "token_expires_at"
    t.boolean  "admin",               limit: 1,     default: false
    t.datetime "last_login_at"
    t.string   "crypted_password",    limit: 128,   default: "",    null: false
    t.integer  "assets_count",        limit: 4,     default: 0,     null: false
    t.string   "display_name",        limit: 255
    t.string   "identity_url",        limit: 255
    t.integer  "pic_id",              limit: 4
    t.integer  "playlists_count",     limit: 4,     default: 0,     null: false
    t.string   "website",             limit: 255
    t.text     "bio",                 limit: 65535
    t.integer  "listens_count",       limit: 4,     default: 0
    t.string   "itunes",              limit: 255
    t.integer  "comments_count",      limit: 4,     default: 0
    t.string   "last_login_ip",       limit: 255
    t.string   "country",             limit: 255
    t.string   "city",                limit: 255
    t.text     "extended_bio",        limit: 65535
    t.string   "myspace",             limit: 255
    t.text     "settings",            limit: 65535
    t.boolean  "plus_enabled",        limit: 1,     default: false
    t.float    "lat",                 limit: 24
    t.float    "lng",                 limit: 24
    t.text     "bio_html",            limit: 65535
    t.integer  "posts_count",         limit: 4,     default: 0
    t.boolean  "moderator",           limit: 1,     default: false
    t.datetime "last_session_at"
    t.string   "browser",             limit: 255
    t.string   "twitter",             limit: 255
    t.integer  "followers_count",     limit: 4,     default: 0
    t.string   "remember_token",      limit: 255
    t.string   "remember_created_at", limit: 255
    t.integer  "login_count",         limit: 4,     default: 0,     null: false
    t.datetime "current_login_at"
    t.string   "current_login_ip",    limit: 255
    t.string   "persistence_token",   limit: 255
    t.string   "perishable_token",    limit: 255
    t.datetime "last_request_at"
    t.integer  "bandwidth_used",      limit: 4,     default: 0
    t.boolean  "greenfield_enabeled", limit: 1,     default: false
    t.boolean  "greenfield_enabled",  limit: 1,     default: false
  end

end
