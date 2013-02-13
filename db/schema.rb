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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120930000305) do

  create_table "assets", :force => true do |t|
    t.string   "mp3_content_type"
    t.string   "mp3_file_name"
    t.integer  "mp3_file_size"
    t.integer  "parent_id"
    t.integer  "site_id"
    t.datetime "created_at"
    t.string   "title"
    t.integer  "thumbnails_count", :default => 0
    t.integer  "user_id"
    t.integer  "length"
    t.string   "album"
    t.string   "permalink"
    t.integer  "samplerate"
    t.integer  "bitrate"
    t.string   "genre"
    t.string   "artist"
    t.integer  "listens_count",    :default => 0
    t.text     "description"
    t.text     "credits"
    t.string   "youtube_embed"
    t.boolean  "private"
    t.float    "hotness"
    t.integer  "favorites_count",  :default => 0
    t.text     "lyrics"
    t.text     "description_html"
    t.float    "listens_per_week"
    t.integer  "comments_count",   :default => 0
    t.datetime "updated_at"
  end

  add_index "assets", ["permalink"], :name => "index_assets_on_permalink"
  add_index "assets", ["user_id", "listens_per_week"], :name => "index_assets_on_user_id_and_listens_per_day"
  add_index "assets", ["user_id"], :name => "index_assets_on_user_id"

  create_table "comments", :force => true do |t|
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commenter_id"
    t.integer  "user_id"
    t.string   "remote_ip"
    t.string   "user_agent"
    t.string   "referer"
    t.boolean  "spam",             :default => false
    t.float    "spaminess"
    t.string   "signature"
    t.boolean  "private",          :default => false
    t.text     "body_html"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commenter_id"], :name => "index_comments_on_commenter_id"
  add_index "comments", ["created_at"], :name => "index_comments_on_created_at"
  add_index "comments", ["spam"], :name => "index_comments_on_spam"

  create_table "facebook_accounts", :force => true do |t|
    t.integer "fb_user_id", :limit => 8
  end

  add_index "facebook_accounts", ["fb_user_id"], :name => "index_facebook_accounts_on_fb_user_id"

  create_table "facebook_addables", :force => true do |t|
    t.string   "profile_chunk_type"
    t.integer  "profile_chunk_id"
    t.integer  "facebook_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "featured_tracks", :force => true do |t|
    t.integer  "position"
    t.integer  "feature_id"
    t.integer  "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "features", :force => true do |t|
    t.integer  "featured_user_id"
    t.integer  "writer_id"
    t.integer  "views_count",      :default => 0
    t.text     "body"
    t.text     "teaser_text"
    t.boolean  "published",        :default => false
    t.boolean  "published_at"
    t.boolean  "datetime"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "follower_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followings", ["follower_id"], :name => "index_followings_on_follower_id"
  add_index "followings", ["user_id"], :name => "index_followings_on_user_id"

  create_table "forums", :force => true do |t|
    t.integer "site_id"
    t.string  "name"
    t.string  "description"
    t.integer "topics_count",     :default => 0
    t.integer "posts_count",      :default => 0
    t.integer "position",         :default => 0
    t.text    "description_html"
    t.string  "state",            :default => "public"
    t.string  "permalink"
  end

  add_index "forums", ["permalink"], :name => "index_forums_on_permalink"
  add_index "forums", ["position"], :name => "index_forums_on_position"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
  end

  create_table "listens", :force => true do |t|
    t.integer  "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "listener_id"
    t.integer  "track_owner_id"
    t.string   "source"
    t.string   "ip"
    t.string   "user_agent"
  end

  add_index "listens", ["asset_id"], :name => "index_listens_on_asset_id"
  add_index "listens", ["created_at"], :name => "index_listens_on_created_at"
  add_index "listens", ["listener_id"], :name => "index_listens_on_listener_id"
  add_index "listens", ["track_owner_id", "created_at"], :name => "index_listens_on_track_owner_id_and_created_at"
  add_index "listens", ["track_owner_id"], :name => "index_listens_on_track_owner_id"

  create_table "logged_exceptions", :force => true do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.datetime "created_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pics", :force => true do |t|
    t.integer  "pic_file_size"
    t.string   "pic_content_type"
    t.string   "pic_file_name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picable_type"
    t.integer  "picable_id"
  end

  add_index "pics", ["picable_id", "picable_type"], :name => "index_pics_on_picable_id_and_picable_type"

  create_table "playlists", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "image"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pic_id"
    t.string   "permalink"
    t.integer  "tracks_count", :default => 0
    t.boolean  "is_mix"
    t.boolean  "private"
    t.boolean  "is_favorite",  :default => false
    t.string   "year"
    t.integer  "position"
  end

  add_index "playlists", ["permalink"], :name => "index_playlists_on_permalink"
  add_index "playlists", ["position"], :name => "index_playlists_on_position"
  add_index "playlists", ["user_id"], :name => "index_playlists_on_user_id"

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.text     "body_html"
    t.boolean  "spam",       :default => false
    t.float    "spaminess"
    t.string   "signature"
  end

  create_table "reportable_cache", :force => true do |t|
    t.string   "model_name",       :limit => 100,                  :null => false
    t.string   "report_name",      :limit => 100,                  :null => false
    t.string   "grouping",         :limit => 10,                   :null => false
    t.string   "aggregation",      :limit => 10,                   :null => false
    t.string   "conditions",       :limit => 100,                  :null => false
    t.float    "value",                           :default => 0.0, :null => false
    t.datetime "reporting_period",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reportable_cache", ["model_name", "report_name", "grouping", "aggregation", "conditions", "reporting_period"], :name => "name_model_grouping_aggregation_period", :unique => true
  add_index "reportable_cache", ["model_name", "report_name", "grouping", "aggregation", "conditions"], :name => "name_model_grouping_agregation"

  create_table "source_files", :force => true do |t|
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size",            :limit => 8
    t.integer  "user_id"
    t.integer  "downloads_count",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hits",            :default => 0
    t.integer  "sticky",          :default => 0
    t.integer  "posts_count",     :default => 0
    t.boolean  "locked",          :default => false
    t.integer  "last_post_id"
    t.datetime "last_updated_at"
    t.integer  "last_user_id"
    t.integer  "site_id"
    t.string   "permalink"
    t.boolean  "spam",            :default => false
    t.float    "spaminess"
    t.string   "signature"
  end

  add_index "topics", ["forum_id", "permalink"], :name => "index_topics_on_forum_id_and_permalink"
  add_index "topics", ["last_updated_at", "forum_id"], :name => "index_topics_on_forum_id_and_last_updated_at"
  add_index "topics", ["sticky", "last_updated_at", "forum_id"], :name => "index_topics_on_sticky_and_last_updated_at"

  create_table "tracks", :force => true do |t|
    t.integer  "playlist_id"
    t.integer  "asset_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_favorite", :default => false
    t.integer  "user_id"
  end

  add_index "tracks", ["asset_id"], :name => "index_tracks_on_asset_id"
  add_index "tracks", ["is_favorite"], :name => "index_tracks_on_is_favorite"
  add_index "tracks", ["playlist_id"], :name => "index_tracks_on_playlist_id"
  add_index "tracks", ["user_id"], :name => "index_tracks_on_user_id"

  create_table "updates", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "revision"
    t.text     "content_html"
    t.string   "permalink"
  end

  create_table "user_reports", :force => true do |t|
    t.integer  "user_id"
    t.string   "category"
    t.text     "description"
    t.string   "params"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "spam",             :default => false
    t.float    "spaminess"
    t.string   "signature"
    t.text     "description_html"
  end

  create_table "users", :force => true do |t|
    t.string   "login",               :limit => 40
    t.string   "email",               :limit => 100
    t.string   "salt",                :limit => 128, :default => "",    :null => false
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "token"
    t.datetime "token_expires_at"
    t.boolean  "admin",                              :default => false
    t.datetime "last_login_at"
    t.string   "crypted_password",    :limit => 128, :default => "",    :null => false
    t.integer  "assets_count",                       :default => 0,     :null => false
    t.string   "display_name"
    t.string   "identity_url"
    t.integer  "pic_id"
    t.integer  "playlists_count",                    :default => 0,     :null => false
    t.string   "website"
    t.text     "bio"
    t.integer  "listens_count",                      :default => 0
    t.string   "itunes"
    t.integer  "comments_count",                     :default => 0
    t.string   "last_login_ip"
    t.string   "country"
    t.string   "city"
    t.text     "extended_bio"
    t.string   "myspace"
    t.text     "settings"
    t.boolean  "plus_enabled",                       :default => false
    t.float    "lat"
    t.float    "lng"
    t.text     "bio_html"
    t.integer  "posts_count",                        :default => 0
    t.boolean  "moderator",                          :default => false
    t.datetime "last_session_at"
    t.string   "browser"
    t.string   "twitter"
    t.integer  "followers_count",                    :default => 0
    t.string   "remember_token"
    t.string   "remember_created_at"
    t.integer  "login_count",                        :default => 0,     :null => false
    t.datetime "current_login_at"
    t.string   "current_login_ip"
    t.string   "persistence_token"
    t.string   "perishable_token"
  end

end
