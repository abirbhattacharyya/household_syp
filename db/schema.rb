# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111226055351) do

  create_table "offers", :force => true do |t|
    t.string   "ip"
    t.string   "response"
    t.integer  "product_id"
    t.float    "price"
    t.integer  "counter"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "token"
  end

  create_table "payments", :force => true do |t|
    t.integer  "offer_id"
    t.integer  "quantity",       :default => 1
    t.string   "voucher_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transaction_id"
    t.string   "email"
    t.float    "price"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "postal_code"
  end

  create_table "products", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.float    "regular_price"
    t.float    "target_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "quantity"
    t.boolean  "is_live",                    :default => true
    t.integer  "category",      :limit => 2, :default => 0
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "address"
    t.string   "phone"
    t.string   "email"
    t.string   "twitter"
    t.string   "facebook_url"
    t.string   "company_url"
    t.string   "logo_url"
    t.string   "header_color"
    t.string   "home_page_image1"
    t.string   "home_page_image2"
    t.string   "home_page_image3"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_blocked",                :default => false
  end

end
