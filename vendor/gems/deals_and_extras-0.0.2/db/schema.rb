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

ActiveRecord::Schema.define(:version => 20110509012305) do

  create_table "attributes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  create_table "countries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
    t.string   "country"
    t.binary   "location_data"
  end

  create_table "data_sources", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_source"
  end

  create_table "favorites", :force => true do |t|
    t.string   "custom_title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offer_id",     :null => false
    t.integer  "user_id",      :null => false
  end

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
    t.string   "description"
    t.boolean  "is_approved",           :default => false
    t.datetime "approved_at"
    t.boolean  "is_deleted",            :default => false
    t.datetime "deleted_at"
    t.string   "hash_id"
    t.string   "price"
    t.string   "operating_hours"
    t.string   "inclusions"
    t.string   "exclusions"
    t.string   "notes"
    t.string   "redemption_policies"
    t.string   "commission_discount"
    t.string   "short_description"
    t.string   "property_id"
    t.integer  "data_source_id"
  end

  create_table "offers_suppliers", :id => false, :force => true do |t|
    t.integer "offer_id"
    t.integer "supplier_id"
  end

  create_table "rating_categories", :force => true do |t|
    t.string   "rating_category", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  create_table "settings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "setting"
  end

  create_table "state_provinces", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
    t.string   "state"
  end

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

  create_table "text_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "text_type"
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login"
    t.string   "password"
    t.string   "email"
  end

end
