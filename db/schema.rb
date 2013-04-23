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

ActiveRecord::Schema.define(:version => 20130410072030) do

  create_table "about_us", :force => true do |t|
    t.text "content"
  end

  create_table "abuses", :force => true do |t|
    t.string   "reason",         :limit => 4000
    t.datetime "created_at"
    t.integer  "abuseable_id"
    t.string   "abuseable_type"
    t.integer  "profile_id"
    t.integer  "owner_id"
    t.integer  "remover_id"
    t.datetime "removed_at"
  end

  add_index "abuses", ["abuseable_type", "abuseable_id"], :name => "index_abuses_on_abuseable_type_and_abuseable_id"

  create_table "activity_stream_events", :force => true do |t|
    t.datetime "created_at", :null => false
    t.string   "klass"
    t.integer  "klass_id"
    t.integer  "profile_id"
    t.string   "action"
    t.integer  "group_id"
  end

  add_index "activity_stream_events", ["created_at"], :name => "index_activity_stream_events_on_created_at"

  create_table "activity_stream_messages", :force => true do |t|
    t.boolean  "active",           :default => true
    t.integer  "primary_photo_id"
    t.string   "title"
    t.string   "description"
    t.string   "owner_link"
    t.string   "event_link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subline"
  end

  create_table "answers", :force => true do |t|
    t.datetime "created_at",                            :null => false
    t.integer  "profile_id",                            :null => false
    t.integer  "question_id",                           :null => false
    t.text     "answer",                                :null => false
    t.boolean  "best_answer",        :default => false
    t.integer  "num_positive_votes", :default => 0,     :null => false
    t.integer  "num_negative_votes", :default => 0,     :null => false
    t.integer  "net_helpful",        :default => 0,     :null => false
    t.integer  "list_pois_count",    :default => 0,     :null => false
  end

  add_index "answers", ["created_at"], :name => "index_answers_on_created_at"
  add_index "answers", ["net_helpful"], :name => "index_answers_on_net_helpful"
  add_index "answers", ["profile_id"], :name => "index_answers_on_profile_id"
  add_index "answers", ["question_id", "best_answer"], :name => "index_answers_on_question_id_and_best_answer"

  create_table "attachments", :force => true do |t|
    t.integer "parent_id"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.string  "type"
    t.integer "owner_id"
    t.string  "owner_type"
  end

  add_index "attachments", ["owner_type", "owner_id"], :name => "index_attachments_on_owner_type_and_owner_id"
  add_index "attachments", ["parent_id", "thumbnail"], :name => "index_attachments_on_parent_id_and_thumbnail", :unique => true
  add_index "attachments", ["type"], :name => "index_attachments_on_type"

  create_table "attributes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  create_table "audit_events", :force => true do |t|
    t.datetime "created_at",  :null => false
    t.integer  "who_id"
    t.string   "name",        :null => false
    t.string   "action"
    t.text     "info"
    t.text     "trace"
    t.string   "target_type"
    t.integer  "target_id"
  end

  create_table "audit_values", :force => true do |t|
    t.integer "audit_id",       :null => false
    t.string  "attribute_name"
    t.text    "value"
  end

  add_index "audit_values", ["attribute_name"], :name => "index_audit_values_on_attribute"
  add_index "audit_values", ["audit_id"], :name => "index_audit_values_on_audit_id"

  create_table "audits", :force => true do |t|
    t.datetime "created_at",     :null => false
    t.string   "auditable_type", :null => false
    t.integer  "auditable_id",   :null => false
    t.string   "action",         :null => false
    t.integer  "who_id"
  end

  add_index "audits", ["action"], :name => "index_audits_on_action"
  add_index "audits", ["auditable_type", "auditable_id"], :name => "index_audits_on_auditable_type_and_auditable_id"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["who_id"], :name => "index_audits_on_who_id"

  create_table "awards", :force => true do |t|
    t.text     "title"
    t.boolean  "visible",    :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "awards", ["created_at"], :name => "index_awards_on_created_at"
  add_index "awards", ["visible"], :name => "index_awards_on_visible"

  create_table "blog_post_text_indices", :force => true do |t|
    t.integer "blog_post_id",         :null => false
    t.text    "title_text"
    t.text    "text_text"
    t.text    "cached_tag_list_text"
    t.text    "author"
  end

  add_index "blog_post_text_indices", ["blog_post_id"], :name => "index_blog_post_text_indices_on_blog_post_id", :unique => true

  create_table "blog_posts", :force => true do |t|
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.integer  "blog_id",                                                               :null => false
    t.integer  "creator_id",                                                            :null => false
    t.string   "title",                                                                 :null => false
    t.text     "text",                                                                  :null => false
    t.integer  "comments_count",                                       :default => 0,   :null => false
    t.integer  "created_at_year_month",                                                 :null => false
    t.string   "cached_tag_list"
    t.integer  "rating_count",                                         :default => 0,   :null => false
    t.integer  "rating_total",                                         :default => 0,   :null => false
    t.decimal  "rating_avg",            :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.integer  "views",                                                :default => 0
    t.string   "source"
    t.string   "link"
    t.string   "guid"
    t.text     "tagline"
    t.string   "creator_type"
    t.integer  "num_positive_votes",                                   :default => 0,   :null => false
    t.integer  "num_negative_votes",                                   :default => 0,   :null => false
    t.integer  "net_helpful",                                          :default => 0,   :null => false
    t.text     "best_image"
    t.integer  "active",                                               :default => 1
  end

  add_index "blog_posts", ["blog_id"], :name => "index_blog_posts_on_blog_id"
  add_index "blog_posts", ["cached_tag_list"], :name => "index_blog_posts_on_cached_tag_list"
  add_index "blog_posts", ["created_at"], :name => "index_blog_posts_on_created_at"
  add_index "blog_posts", ["created_at_year_month"], :name => "index_blog_posts_on_created_at_year_month"
  add_index "blog_posts", ["creator_id"], :name => "index_blog_posts_on_profile_id"
  add_index "blog_posts", ["net_helpful"], :name => "index_blog_posts_on_net_helpful"

  create_table "blogs", :force => true do |t|
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "owner_id",                        :null => false
    t.string   "owner_type",                      :null => false
    t.integer  "blog_posts_count", :default => 0, :null => false
  end

  add_index "blogs", ["owner_type", "owner_id"], :name => "index_blogs_on_owner_type_and_owner_id", :unique => true

  create_table "bookmarks", :force => true do |t|
    t.datetime "created_at"
    t.integer  "question_id"
    t.integer  "profile_id"
  end

  add_index "bookmarks", ["profile_id"], :name => "index_bookmarks_on_profile_id"

  create_table "booth_marketing_messages", :force => true do |t|
    t.boolean  "active"
    t.text     "link_to_url"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chat_topic_indices", :force => true do |t|
    t.integer  "topic_id",        :null => false
    t.text     "chat_title_text"
    t.text     "topic_text"
    t.text     "posts_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chat_topic_indices", ["chat_title_text", "topic_text", "posts_text"], :name => "fulltext_topic"
  add_index "chat_topic_indices", ["posts_text"], :name => "fulltext_topic_posts"
  add_index "chat_topic_indices", ["topic_id"], :name => "index_chat_topic_indices_on_topic_id", :unique => true
  add_index "chat_topic_indices", ["topic_text"], :name => "fulltext_post_topics"

  create_table "chats", :force => true do |t|
    t.integer  "host_id"
    t.string   "title"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration"
    t.datetime "start_at"
    t.integer  "active",             :default => 1
    t.text     "description"
    t.integer  "primary_photo_id"
    t.integer  "notifications_sent", :default => 0
  end

  create_table "comments", :force => true do |t|
    t.integer  "profile_id",                                   :null => false
    t.integer  "owner_id",                                     :null => false
    t.string   "text",       :limit => 4000,                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "owner_type"
    t.boolean  "active",                     :default => true
  end

  add_index "comments", ["created_at"], :name => "index_comments_on_created_at"
  add_index "comments", ["owner_type", "owner_id"], :name => "index_comments_on_owner_type_and_owner_id"
  add_index "comments", ["profile_id"], :name => "index_comments_on_profile_id"

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "owner_id"
    t.integer  "primary_photo_id"
    t.integer  "active",           :default => 1, :null => false
  end

  create_table "company_stream_events", :force => true do |t|
    t.string   "klass"
    t.integer  "klass_id"
    t.integer  "profile_id"
    t.string   "action"
    t.integer  "company_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "company_stream_events", ["company_id"], :name => "index_company_stream_events_on_company_id"
  add_index "company_stream_events", ["created_at"], :name => "index_company_stream_events_on_created_at"

  create_table "confirmed_email_pccs", :force => true do |t|
    t.string   "email"
    t.string   "pcc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "location_data"
    t.string   "name"
    t.string   "cctld"
    t.string   "srw_country_code"
    t.string   "srw_region_code"
  end

  create_table "custom_reports", :force => true do |t|
    t.string   "name"
    t.text     "form"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_sources", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_source"
  end

  create_table "default_widgets", :force => true do |t|
    t.text "content"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "favorites", :force => true do |t|
    t.string   "custom_title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offer_id",     :null => false
    t.integer  "user_id",      :null => false
  end

  create_table "gallery_photos", :force => true do |t|
    t.string   "caption"
    t.integer  "views"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "uploader_id"
    t.string   "cached_tag_list"
    t.integer  "rating_count",                                   :default => 0,   :null => false
    t.integer  "rating_total",                                   :default => 0,   :null => false
    t.decimal  "rating_avg",      :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.integer  "comments_count",                                 :default => 0
  end

  add_index "gallery_photos", ["cached_tag_list"], :name => "index_gallery_photos_on_cached_tag_list"

  create_table "getthere_booking_text_indices", :force => true do |t|
    t.integer  "getthere_booking_id",            :null => false
    t.text     "start_location_text"
    t.text     "locations_text"
    t.text     "start_airport_code_text"
    t.text     "destination_airport_codes_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "getthere_booking_text_indices", ["getthere_booking_id"], :name => "index_getthere_booking_text_indices_on_getthere_booking_id", :unique => true
  add_index "getthere_booking_text_indices", ["locations_text", "destination_airport_codes_text"], :name => "fulltext_getthere_booking_arrivals"
  add_index "getthere_booking_text_indices", ["start_location_text", "locations_text", "start_airport_code_text", "destination_airport_codes_text"], :name => "fulltext_getthere_booking"
  add_index "getthere_booking_text_indices", ["start_location_text", "start_airport_code_text"], :name => "fulltext_getthere_booking_departures"

  create_table "getthere_bookings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ord_key",                                      :null => false
    t.datetime "start_time",                                   :null => false
    t.datetime "end_time",                                     :null => false
    t.text     "xml",                                          :null => false
    t.string   "locations",                                    :null => false
    t.integer  "profile_id",                                   :null => false
    t.string   "property_ids"
    t.string   "start_location"
    t.boolean  "public",                    :default => false
    t.string   "start_airport_code"
    t.string   "destination_airport_codes"
  end

  add_index "getthere_bookings", ["destination_airport_codes"], :name => "index_getthere_bookings_on_destination_airport_codes"
  add_index "getthere_bookings", ["end_time"], :name => "index_bookings_on_end_time"
  add_index "getthere_bookings", ["locations"], :name => "index_getthere_bookings_on_locations"
  add_index "getthere_bookings", ["ord_key"], :name => "index_bookings_on_ord_key"
  add_index "getthere_bookings", ["profile_id"], :name => "index_bookings_on_profile_id"
  add_index "getthere_bookings", ["public"], :name => "index_getthere_bookings_on_public"
  add_index "getthere_bookings", ["start_airport_code"], :name => "index_getthere_bookings_on_start_airport_code"
  add_index "getthere_bookings", ["start_location"], :name => "index_getthere_bookings_on_start_location"
  add_index "getthere_bookings", ["start_time"], :name => "index_bookings_on_start_time"

  create_table "getthere_next_queries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "request_type", :null => false
    t.string   "start_id"
  end

  add_index "getthere_next_queries", ["request_type"], :name => "index_next_queries_on_request_type"

  create_table "group_announcements", :force => true do |t|
    t.text     "content"
    t.integer  "group_id"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  add_index "group_announcements", ["group_id"], :name => "index_group_announcements_on_group_id", :unique => true

  create_table "group_invitations", :force => true do |t|
    t.integer  "group_id"
    t.integer  "receiver_id"
    t.integer  "sender_id"
    t.datetime "created_at",  :null => false
    t.string   "type",        :null => false
  end

  add_index "group_invitations", ["created_at"], :name => "index_group_invitations_on_created_at"
  add_index "group_invitations", ["group_id"], :name => "index_group_invitations_on_group_id"
  add_index "group_invitations", ["receiver_id"], :name => "index_group_invitations_on_receiver_id"
  add_index "group_invitations", ["sender_id"], :name => "index_group_invitations_on_sender_id"
  add_index "group_invitations", ["type"], :name => "index_group_invitations_on_type"

  create_table "group_links", :force => true do |t|
    t.string   "url"
    t.string   "text"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_memberships", :force => true do |t|
    t.integer  "profile_id",                                :null => false
    t.integer  "group_id",                                  :null => false
    t.datetime "created_at"
    t.datetime "last_visited"
    t.boolean  "moderator",              :default => false, :null => false
    t.text     "email_preferences_yaml"
  end

  add_index "group_memberships", ["created_at"], :name => "index_group_memberships_on_created_at"
  add_index "group_memberships", ["group_id", "profile_id"], :name => "index_group_memberships_on_group_id_and_profile_id", :unique => true
  add_index "group_memberships", ["moderator"], :name => "index_group_memberships_on_moderator"
  add_index "group_memberships", ["profile_id"], :name => "index_group_memberships_on_profile_id"

  create_table "group_posts", :force => true do |t|
    t.text     "post",                          :null => false
    t.integer  "group_id"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count", :default => 0, :null => false
  end

  add_index "group_posts", ["created_at"], :name => "index_group_posts_on_created_at"
  add_index "group_posts", ["group_id"], :name => "index_group_posts_on_group_id"
  add_index "group_posts", ["profile_id"], :name => "index_group_posts_on_profile_id"

  create_table "group_text_indices", :force => true do |t|
    t.integer "group_id",         :null => false
    t.text    "name_text"
    t.text    "description_text"
    t.text    "tags_text"
  end

  add_index "group_text_indices", ["group_id"], :name => "index_group_text_indices_on_group_id", :unique => true
  add_index "group_text_indices", ["name_text", "description_text", "tags_text"], :name => "fulltext_group"

  create_table "groups", :force => true do |t|
    t.string   "name",                    :limit => 100,                :null => false
    t.string   "description",             :limit => 500,                :null => false
    t.datetime "created_at"
    t.integer  "primary_photo_id"
    t.datetime "updated_at"
    t.string   "tags",                    :limit => 300,                :null => false
    t.integer  "group_memberships_count",                :default => 0, :null => false
    t.integer  "group_type",                             :default => 0, :null => false
    t.integer  "last_updated_by",                                       :null => false
    t.datetime "content_updated_at"
    t.integer  "activity_points",                        :default => 0, :null => false
    t.integer  "activity_status",                        :default => 0, :null => false
    t.date     "no_memberships_on"
    t.integer  "owner_id"
    t.integer  "sponsor_account_id"
    t.integer  "views",                                  :default => 0
    t.integer  "company_id",                             :default => 0
    t.integer  "active",                                 :default => 1
    t.integer  "de_flag"
    t.string   "booth_video_location"
  end

  add_index "groups", ["activity_points"], :name => "index_groups_on_activity_points"
  add_index "groups", ["activity_status"], :name => "index_groups_on_activity_status"
  add_index "groups", ["created_at"], :name => "index_groups_on_created_at"
  add_index "groups", ["group_memberships_count"], :name => "index_groups_on_group_memberships_count"
  add_index "groups", ["group_type"], :name => "index_groups_on_group_type"
  add_index "groups", ["name"], :name => "index_groups_on_name", :unique => true
  add_index "groups", ["no_memberships_on"], :name => "index_groups_on_no_memberships_on"

  create_table "karma_histories", :force => true do |t|
    t.integer "profile_id"
    t.integer "month"
    t.integer "year"
    t.integer "value"
    t.integer "karma_login", :default => 0
  end

  add_index "karma_histories", ["profile_id", "month", "year"], :name => "karma_month_index", :unique => true

  create_table "list_pois", :force => true do |t|
    t.string  "owner_type", :null => false
    t.integer "owner_id",   :null => false
    t.integer "poi_id",     :null => false
    t.integer "position"
  end

  add_index "list_pois", ["owner_type", "owner_id"], :name => "index_list_pois_on_owner_type_and_owner_id"
  add_index "list_pois", ["poi_id"], :name => "index_list_pois_on_poi_id"
  add_index "list_pois", ["position"], :name => "index_list_pois_on_position"

  create_table "location_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location_type"
  end

  create_table "locations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.integer  "location_type_id"
    t.string   "latitude"
    t.string   "longitude"
    t.integer  "state_province_id"
    t.integer  "country_id"
    t.string   "city"
    t.binary   "location_data"
  end

  create_table "locations_offers", :id => false, :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offer_id"
    t.integer  "location_id"
  end

  create_table "marketing_messages", :force => true do |t|
    t.boolean "is_default",  :default => false
    t.boolean "active",      :default => false
    t.text    "link_to_url"
    t.string  "image_path"
  end

  add_index "marketing_messages", ["active"], :name => "index_marketing_messages_on_active"
  add_index "marketing_messages", ["is_default"], :name => "index_marketing_messages_on_is_default"

  create_table "news_followers", :force => true do |t|
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", :force => true do |t|
    t.integer  "receiver_id",                      :null => false
    t.integer  "sender_id",                        :null => false
    t.text     "message",                          :null => false
    t.datetime "created_at",                       :null => false
    t.integer  "replied_to"
    t.boolean  "private",       :default => false
    t.string   "receiver_type",                    :null => false
  end

  add_index "notes", ["created_at"], :name => "index_notes_on_created_at"
  add_index "notes", ["private"], :name => "index_notes_on_private"
  add_index "notes", ["receiver_type", "receiver_id"], :name => "index_notes_on_receiver_type_and_receiver_id"
  add_index "notes", ["sender_id"], :name => "index_notes_on_sender_id"

  create_table "offer_attributes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offer_id"
    t.integer  "attribute_id"
    t.string   "attribute"
  end

  create_table "offer_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "offer_type"
  end

  create_table "offers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offer_type_id"
    t.date     "sell_effective_date"
    t.date     "sell_discontinue_date"
    t.text     "description"
    t.boolean  "is_approved",                       :default => false
    t.datetime "approved_at"
    t.boolean  "is_deleted",                        :default => false
    t.datetime "deleted_at"
    t.string   "hash_id"
    t.string   "price"
    t.string   "operating_hours"
    t.string   "inclusions"
    t.string   "exclusions"
    t.string   "notes"
    t.string   "redemption_policies"
    t.string   "commission_discount"
    t.text     "short_description"
    t.string   "property_id"
    t.integer  "data_source_id"
    t.text     "raw_xml"
    t.text     "url"
    t.string   "cached_supplier_name"
    t.integer  "cached_reviews_count"
    t.float    "cached_positive_review_percentage"
  end

  create_table "offers_suppliers", :id => false, :force => true do |t|
    t.integer "offer_id"
    t.integer "supplier_id"
  end

  create_table "participants", :force => true do |t|
    t.integer  "chat_id"
    t.integer  "profile_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "presenter",  :default => false
    t.text     "bio"
  end

  create_table "poi_lists", :force => true do |t|
    t.datetime "created_at",                         :null => false
    t.string   "name"
    t.integer  "owner_id"
    t.integer  "list_pois_count", :default => 0,     :null => false
    t.boolean  "private",         :default => false
    t.boolean  "imported",        :default => false
  end

  add_index "poi_lists", ["created_at"], :name => "index_poi_lists_on_created_at"
  add_index "poi_lists", ["imported"], :name => "index_poi_lists_on_imported"
  add_index "poi_lists", ["name"], :name => "index_poi_lists_on_name"
  add_index "poi_lists", ["owner_id"], :name => "index_poi_lists_on_owner_id"
  add_index "poi_lists", ["private"], :name => "index_poi_lists_on_private"

  create_table "pois", :force => true do |t|
    t.datetime "created_at",                                                         :null => false
    t.string   "poi_type",                                                           :null => false
    t.string   "name",                                                               :null => false
    t.string   "loc_name"
    t.decimal  "loc_lat",         :precision => 13, :scale => 10
    t.decimal  "loc_lng",         :precision => 13, :scale => 10
    t.string   "loc_address1"
    t.string   "loc_address2"
    t.string   "loc_city"
    t.string   "loc_state"
    t.string   "loc_zip"
    t.string   "loc_country"
    t.string   "url"
    t.string   "photo_url"
    t.integer  "rating_count",                                    :default => 0,     :null => false
    t.integer  "rating_total",                                    :default => 0,     :null => false
    t.decimal  "rating_avg",      :precision => 10, :scale => 2,  :default => 0.0,   :null => false
    t.integer  "comments_count",                                  :default => 0,     :null => false
    t.integer  "last_updated_by",                                                    :null => false
    t.datetime "last_updated_at",                                                    :null => false
    t.integer  "created_by",                                                         :null => false
    t.boolean  "imported",                                        :default => false, :null => false
    t.string   "external_id"
    t.boolean  "preferred",                                       :default => false
    t.float    "popularity",                                      :default => 0.0,   :null => false
    t.text     "description"
  end

  add_index "pois", ["created_by"], :name => "index_trip_elements_on_created_by"
  add_index "pois", ["external_id"], :name => "index_trip_elements_on_external_id"
  add_index "pois", ["imported"], :name => "index_trip_elements_on_imported"
  add_index "pois", ["loc_lat", "loc_lng"], :name => "index_trip_elements_on_loc_lat_and_loc_lng"
  add_index "pois", ["name"], :name => "index_trip_elements_on_name"
  add_index "pois", ["poi_type"], :name => "index_trip_elements_on_element_type"
  add_index "pois", ["popularity"], :name => "index_plan_elements_on_popularity"
  add_index "pois", ["rating_avg"], :name => "index_trip_elements_on_rating_avg"

  create_table "posts", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "author_id"
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_awards", :force => true do |t|
    t.integer  "profile_id"
    t.integer  "award_id"
    t.boolean  "is_default", :default => false
    t.boolean  "visible",    :default => true
    t.string   "awarded_by",                    :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "profile_awards", ["award_id"], :name => "index_profile_awards_on_award_id"
  add_index "profile_awards", ["created_at"], :name => "index_profile_awards_on_created_at"
  add_index "profile_awards", ["is_default"], :name => "index_profile_awards_on_is_default"
  add_index "profile_awards", ["profile_id", "award_id"], :name => "index_profile_awards_on_profile_id_and_award_id"
  add_index "profile_awards", ["visible"], :name => "index_profile_awards_on_visible"

  create_table "profile_registration_fields", :force => true do |t|
    t.integer  "profile_id"
    t.integer  "site_registration_field_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_text_indices", :force => true do |t|
    t.integer "profile_id",                       :null => false
    t.text    "profile_text"
    t.text    "answers_text", :limit => 16777215
  end

  add_index "profile_text_indices", ["profile_id"], :name => "index_profile_text_indices_on_profile_id", :unique => true
  add_index "profile_text_indices", ["profile_text", "answers_text"], :name => "fulltext_profile"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id",                                                                    :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.string   "profile_2"
    t.string   "first_name",                                                                 :null => false
    t.string   "last_name",                                                                  :null => false
    t.string   "question_7",                              :limit => 1000
    t.string   "question_3",                              :limit => 1000
    t.string   "question_11",                             :limit => 1000
    t.string   "question_10",                             :limit => 1000
    t.string   "question_4",                              :limit => 1000
    t.text     "exclude_terms"
    t.string   "question_1",                              :limit => 1000
    t.string   "question_2",                              :limit => 1000
    t.string   "question_5",                              :limit => 1000
    t.string   "question_6",                              :limit => 1000
    t.string   "question_8",                              :limit => 1000
    t.string   "question_9",                              :limit => 1000
    t.string   "question_12",                             :limit => 1000
    t.string   "profile_1"
    t.string   "profile_7"
    t.string   "profile_3"
    t.string   "profile_5"
    t.string   "profile_6"
    t.string   "profile_4"
    t.string   "alt_first_name"
    t.string   "alt_last_name"
    t.integer  "profile_views",                                           :default => 0,     :null => false
    t.integer  "status",                                                  :default => 1,     :null => false
    t.datetime "about_me_updated_at"
    t.integer  "karma_points",                                            :default => 0,     :null => false
    t.integer  "karma_login_points",                                      :default => 0,     :null => false
    t.boolean  "completed_once",                                          :default => false, :null => false
    t.date     "last_login_date"
    t.integer  "primary_photo_id"
    t.integer  "summary_email_status",                                    :default => 1
    t.integer  "referral_email_status",                                   :default => 1
    t.integer  "closing_email_status",                                    :default => 1
    t.integer  "best_answer_email_status",                                :default => 1
    t.integer  "group_invitation_email_status",                           :default => 1
    t.text     "widget_config"
    t.boolean  "visible",                                                 :default => true,  :null => false
    t.text     "knowledge"
    t.string   "screen_name",                                                                :null => false
    t.datetime "last_accessed"
    t.integer  "old_karma_points"
    t.boolean  "karma_abducted",                                          :default => false, :null => false
    t.string   "api_key"
    t.integer  "list_pois_count",                                         :default => 0,     :null => false
    t.string   "roles"
    t.string   "profile_8"
    t.string   "profile_9"
    t.string   "profile_10"
    t.string   "profile_11"
    t.string   "profile_12"
    t.integer  "group_slots_override"
    t.integer  "note_email_status",                                       :default => 1
    t.integer  "group_note_email_status",                                 :default => 1
    t.integer  "watched_question_answer_email_status",                    :default => 1
    t.integer  "recommendation_on_question_email_status",                 :default => 1
    t.integer  "matched_question_email_status",                           :default => 1
    t.integer  "group_blog_post_email_status",                            :default => 1
    t.integer  "group_post_email_status",                                 :default => 1
    t.integer  "group_referral_email_status",                             :default => 1
    t.integer  "sponsor_account_id"
    t.boolean  "following_profile_blog_notification",                     :default => true
    t.boolean  "new_comment_on_blog_notification",                        :default => true
    t.boolean  "new_reply_on_answer_notification",                        :default => true
    t.datetime "last_sent_welcome_at"
    t.boolean  "travel_email_status",                                     :default => true
    t.integer  "company_id"
    t.string   "pcc"
    t.boolean  "company_blog_notification",                               :default => true
    t.datetime "created_at"
  end

  add_index "profiles", ["alt_first_name"], :name => "index_profiles_on_alt_first_name"
  add_index "profiles", ["alt_last_name"], :name => "index_profiles_on_alt_last_name"
  add_index "profiles", ["api_key"], :name => "index_profiles_on_api_key"
  add_index "profiles", ["first_name"], :name => "index_profiles_on_first_name"
  add_index "profiles", ["karma_points"], :name => "index_profiles_on_karma_points"
  add_index "profiles", ["last_accessed"], :name => "index_profiles_on_last_accessed"
  add_index "profiles", ["last_name"], :name => "index_profiles_on_last_name"
  add_index "profiles", ["primary_photo_id"], :name => "index_profiles_on_primary_photo_id"
  add_index "profiles", ["profile_views"], :name => "index_profiles_on_profile_views"
  add_index "profiles", ["roles"], :name => "index_profiles_on_roles"
  add_index "profiles", ["screen_name"], :name => "index_profiles_on_screen_name"
  add_index "profiles", ["status"], :name => "index_profiles_on_status"
  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id", :unique => true
  add_index "profiles", ["visible"], :name => "index_profiles_on_visible"

  create_table "question_profile_exclude_matches", :force => true do |t|
    t.integer "question_id", :null => false
    t.integer "profile_id",  :null => false
  end

  add_index "question_profile_exclude_matches", ["question_id", "profile_id"], :name => "qpim_unique_pair", :unique => true

  create_table "question_profile_matches", :force => true do |t|
    t.integer "question_id",                    :null => false
    t.integer "profile_id",                     :null => false
    t.float   "rank",                           :null => false
    t.integer "order",                          :null => false
    t.boolean "notified",    :default => false
  end

  add_index "question_profile_matches", ["order"], :name => "index_question_profile_matches_on_order"
  add_index "question_profile_matches", ["profile_id"], :name => "index_question_profile_matches_on_profile_id"
  add_index "question_profile_matches", ["question_id", "profile_id"], :name => "index_question_profile_matches_on_question_id_and_profile_id", :unique => true
  add_index "question_profile_matches", ["rank"], :name => "index_question_profile_matches_on_rank"

  create_table "question_referrals", :force => true do |t|
    t.integer  "question_id"
    t.integer  "owner_id"
    t.integer  "referer_id"
    t.boolean  "active",      :default => true, :null => false
    t.datetime "created_at",                    :null => false
    t.string   "owner_type",                    :null => false
  end

  add_index "question_referrals", ["active"], :name => "index_question_referrals_on_active"
  add_index "question_referrals", ["created_at"], :name => "index_question_referrals_on_created_at"
  add_index "question_referrals", ["owner_type", "owner_id"], :name => "index_question_referrals_on_owner_type_and_owner_id"
  add_index "question_referrals", ["question_id"], :name => "index_question_referrals_on_question_id"
  add_index "question_referrals", ["referer_id"], :name => "index_question_referrals_on_referer_id"

  create_table "question_text_indices", :force => true do |t|
    t.integer "question_id",   :null => false
    t.text    "question_text"
  end

  add_index "question_text_indices", ["question_id"], :name => "index_question_text_indices_on_question_id", :unique => true
  add_index "question_text_indices", ["question_text"], :name => "fulltext_question"

  create_table "questions", :force => true do |t|
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.date     "open_until",                                               :null => false
    t.integer  "profile_id",                                               :null => false
    t.text     "question",                                                 :null => false
    t.boolean  "per_answer_notification",               :default => false
    t.datetime "author_viewed_at"
    t.integer  "answers_count",                         :default => 0
    t.boolean  "daily_summary_email",                   :default => false
    t.boolean  "directed_question",                     :default => false, :null => false
    t.string   "category",                :limit => 40
    t.integer  "answers_poi_count",                     :default => 0,     :null => false
    t.integer  "company_id",                            :default => 0,     :null => false
    t.integer  "active",                                :default => 1
  end

  add_index "questions", ["answers_count"], :name => "index_questions_on_answers_count"
  add_index "questions", ["category"], :name => "index_questions_on_category"
  add_index "questions", ["created_at"], :name => "index_questions_on_created_at"
  add_index "questions", ["open_until"], :name => "index_questions_on_open_until"
  add_index "questions", ["profile_id"], :name => "index_questions_on_profile_id"

  create_table "rating_categories", :force => true do |t|
    t.string   "rating_category", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer "rater_id",                  :null => false
    t.integer "rated_id",                  :null => false
    t.string  "rated_type",                :null => false
    t.integer "rating",     :default => 0, :null => false
  end

  add_index "ratings", ["rated_type", "rated_id", "rater_id"], :name => "index_ratings_on_rated_type_and_rated_id_and_rater_id", :unique => true
  add_index "ratings", ["rater_id"], :name => "index_ratings_on_rater_id"

  create_table "replies", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "answer_id",  :null => false
    t.integer  "profile_id", :null => false
    t.text     "text",       :null => false
  end

  add_index "replies", ["answer_id"], :name => "index_replies_on_answer_id", :unique => true

  create_table "review_type", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "review_type"
    t.integer  "review_id"
  end

  create_table "reviews", :force => true do |t|
    t.integer  "offer_id",           :null => false
    t.boolean  "rating",             :null => false
    t.integer  "rating_category_id", :null => false
    t.string   "review"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "temp_user_id"
  end

  create_table "rss_feeds", :force => true do |t|
    t.integer  "blog_id"
    t.integer  "profile_id"
    t.string   "feed_url"
    t.string   "last_etag"
    t.string   "description"
    t.integer  "active",           :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "tagline"
    t.integer  "primary_photo_id"
  end

  create_table "rsvps", :force => true do |t|
    t.integer  "chat_id"
    t.integer  "profile_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "setting"
  end

  create_table "showcase_marketing_messages", :force => true do |t|
    t.boolean  "active"
    t.text     "link_to_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "showcase_texts", :force => true do |t|
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_configs", :force => true do |t|
    t.string   "site_name"
    t.text     "disclaimer"
    t.boolean  "terms_acceptance_required", :default => true
    t.boolean  "open_registration",         :default => true
    t.boolean  "registration_queue",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "theme"
    t.boolean  "viewable_karma",            :default => true
    t.integer  "user_max",                  :default => 0
    t.string   "feedback_email"
    t.string   "email_from_address"
    t.string   "analytics_tracker_code"
    t.string   "site_base_url"
    t.boolean  "api_enabled",               :default => false
    t.boolean  "rank_enabled",              :default => false
    t.string   "monitor_email_address"
    t.boolean  "frozen_emails",             :default => false
    t.boolean  "ssl_enabled",               :default => false
    t.string   "welcome_promo_title_1",     :default => ""
    t.string   "welcome_promo_1",           :default => ""
    t.string   "welcome_promo_title_2",     :default => ""
    t.string   "welcome_promo_2",           :default => ""
    t.string   "welcome_promo_title_3",     :default => ""
    t.string   "welcome_promo_3",           :default => ""
  end

  create_table "site_profile_cards", :force => true do |t|
    t.integer  "site_profile_field_id"
    t.integer  "position"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_profile_fields", :force => true do |t|
    t.string   "label"
    t.string   "question"
    t.boolean  "completes_profile", :default => true
    t.boolean  "matchable",         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_profile_question_sections", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_profile_questions", :force => true do |t|
    t.string   "label"
    t.string   "question"
    t.string   "example"
    t.boolean  "completes_profile"
    t.boolean  "matchable"
    t.integer  "site_profile_question_section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  create_table "site_question_categories", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_registration_fields", :force => true do |t|
    t.string   "label"
    t.string   "field_name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "required",              :default => true
    t.text     "options"
    t.integer  "site_profile_field_id"
  end

  create_table "site_stat_histories", :force => true do |t|
    t.integer  "julian_date"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_stat_histories", ["julian_date", "name"], :name => "index_site_stat_histories_on_julian_date_and_name", :unique => true

  create_table "site_visits", :force => true do |t|
    t.integer  "profile_id"
    t.integer  "julian_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsor_accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.integer  "groups_allowed"
  end

  create_table "state_provinces", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
    t.string   "state"
  end

  create_table "status_text_indices", :force => true do |t|
    t.integer  "status_id",   :null => false
    t.text     "body_text"
    t.text     "author_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "status_text_indices", ["author_text"], :name => "fulltext_status_author"
  add_index "status_text_indices", ["body_text", "author_text"], :name => "fulltext_status"
  add_index "status_text_indices", ["body_text"], :name => "fulltext_status_body"
  add_index "status_text_indices", ["status_id"], :name => "index_status_text_indices_on_status_id", :unique => true

  create_table "statuses", :force => true do |t|
    t.string   "body"
    t.integer  "profile_id"
    t.datetime "created_at"
  end

  add_index "statuses", ["profile_id"], :name => "index_statuses_on_profile_id"

  create_table "supplier_attributes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.integer  "attribute_id"
    t.string   "attribute"
  end

  create_table "supplier_texts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.integer  "text_type_id"
    t.string   "supplier_text"
  end

  create_table "supplier_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "supplier_type"
  end

  create_table "supplier_users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "supplier_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "supplier_users", ["email"], :name => "index_supplier_users_on_email", :unique => true
  add_index "supplier_users", ["reset_password_token"], :name => "index_supplier_users_on_reset_password_token", :unique => true

  create_table "suppliers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_type_id"
    t.string   "supplier_external_reference_id"
    t.integer  "data_source_id"
    t.string   "supplier_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "address_3"
    t.string   "city"
    t.string   "state_province_id"
    t.string   "postal_code"
    t.string   "country_id"
  end

  create_table "system_announcements", :force => true do |t|
    t.text     "content"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "temp_users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "pcc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "terms_and_conditions", :force => true do |t|
    t.text "content"
  end

  create_table "text_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "text_type"
  end

  create_table "top_terms", :force => true do |t|
    t.string  "term",   :null => false
    t.integer "rank",   :null => false
    t.string  "domain", :null => false
  end

  add_index "top_terms", ["domain", "rank"], :name => "index_top_terms_on_domain_and_rank"
  add_index "top_terms", ["domain", "term"], :name => "index_top_terms_on_domain_and_term", :unique => true
  add_index "top_terms", ["rank"], :name => "index_top_terms_on_rank"

  create_table "topics", :force => true do |t|
    t.integer  "chat_id"
    t.integer  "owner_id"
    t.string   "title"
    t.string   "status"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_sync_jobs", :force => true do |t|
    t.string   "status"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "options"
    t.text     "response_hash"
    t.string   "response_message"
    t.text     "log_output",       :limit => 16777215
    t.text     "data",             :limit => 16777215
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",                 :limit => 40
    t.string   "salt",                             :limit => 40
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "temp_crypted_password",            :limit => 40
    t.string   "access_key"
    t.string   "sso_id"
    t.boolean  "terms_accepted",                                 :default => false
    t.boolean  "sync_exclude",                                   :default => false, :null => false
    t.datetime "password_changed_at"
    t.datetime "temp_crypted_password_expires_at"
    t.integer  "unsuccessful_login_attempts",                    :default => 0
    t.datetime "locked_until"
    t.text     "crypted_password_history"
    t.integer  "tfce_req_nonce"
    t.integer  "tfce_res_nonce"
    t.integer  "facebook_id",                      :limit => 8
    t.text     "facebook_graph"
    t.string   "srw_agent_id"
    t.text     "srw_ticket"
    t.boolean  "take_survey",                                    :default => false
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["sso_id"], :name => "index_users_on_external_id"

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "panda_video_id"
    t.string   "image_url"
    t.string   "filename"
    t.string   "extname"
    t.integer  "profile_id"
    t.text     "tag_list_cache"
    t.boolean  "encoded",        :default => false
  end

  create_table "visitations", :force => true do |t|
    t.integer  "profile_id", :null => false
    t.integer  "owner_id",   :null => false
    t.datetime "updated_at"
    t.string   "owner_type", :null => false
  end

  add_index "visitations", ["owner_type", "owner_id", "updated_at"], :name => "index_visitations_on_owner_type_and_owner_id_and_updated_at"

  create_table "votes", :force => true do |t|
    t.integer "owner_id"
    t.integer "profile_id"
    t.boolean "vote_value", :null => false
    t.string  "owner_type", :null => false
  end

  add_index "votes", ["owner_type", "owner_id", "profile_id"], :name => "index_votes_on_owner_type_and_owner_id_and_profile_id", :unique => true
  add_index "votes", ["vote_value"], :name => "index_votes_on_vote_value"

  create_table "watch_events", :force => true do |t|
    t.datetime "created_at",                          :null => false
    t.string   "watchable_type",                      :null => false
    t.integer  "watchable_id",                        :null => false
    t.string   "action_item_type",                    :null => false
    t.integer  "action_item_id",                      :null => false
    t.boolean  "private",          :default => false, :null => false
    t.string   "action"
    t.integer  "profile_id"
  end

  add_index "watch_events", ["watchable_type", "watchable_id", "private"], :name => "index_watch_events_on_watchable_and_private"

  create_table "watches", :force => true do |t|
    t.datetime "created_at",     :null => false
    t.integer  "watcher_id",     :null => false
    t.string   "watchable_type", :null => false
    t.integer  "watchable_id",   :null => false
  end

  add_index "watches", ["watchable_type", "watchable_id"], :name => "index_watches_on_watchable_type_and_watchable_id"
  add_index "watches", ["watcher_id", "watchable_type", "watchable_id"], :name => "index_watches_on_watcher_id_and_watchable_type_and_watchable_id", :unique => true

  create_table "welcome_emails", :force => true do |t|
    t.text   "content"
    t.string "subject"
  end

  create_table "welcome_notes", :force => true do |t|
    t.integer "profile_id"
    t.text    "text"
  end

  create_table "widgets", :force => true do |t|
    t.text     "content"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
