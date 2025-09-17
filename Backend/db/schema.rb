# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_09_16_213000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discounts", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "discount_type", null: false
    t.decimal "discount_value", precision: 10, scale: 2, null: false
    t.decimal "minimum_amount", precision: 10, scale: 2, default: "0.0"
    t.boolean "active", default: true
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_discounts_on_active"
    t.index ["starts_at", "ends_at"], name: "index_discounts_on_starts_at_and_ends_at"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "sku", null: false
    t.string "category", null: false
    t.integer "stock_quantity", default: 0
    t.integer "low_stock_threshold", default: 5
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_products_on_active"
    t.index ["category"], name: "index_products_on_category"
    t.index ["sku"], name: "index_products_on_sku", unique: true
  end

  create_table "sale_items", force: :cascade do |t|
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "line_total", precision: 10, scale: 2, null: false
    t.integer "sale_id", null: false
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sale_items_on_product_id"
    t.index ["sale_id", "product_id"], name: "index_sale_items_on_sale_id_and_product_id", unique: true
    t.index ["sale_id"], name: "index_sale_items_on_sale_id"
  end

  create_table "sales", force: :cascade do |t|
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.decimal "tax_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.string "status", default: "pending", null: false
    t.string "payment_method", null: false
    t.text "notes"
    t.integer "user_id", null: false
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "anonymous_customer_name"
    t.index ["created_at"], name: "index_sales_on_created_at"
    t.index ["customer_id"], name: "index_sales_on_customer_id"
    t.index ["status"], name: "index_sales_on_status"
    t.index ["user_id"], name: "index_sales_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "role", default: "employee", null: false
    t.string "password_digest", null: false
    t.string "two_factor_secret"
    t.boolean "two_factor_enabled", default: false
    t.string "phone"
    t.datetime "last_sign_in_at"
    t.datetime "current_sign_in_at"
    t.integer "sign_in_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "unlock_token"
    t.text "two_factor_backup_codes"
    t.datetime "password_changed_at"
    t.boolean "must_change_password", default: false, null: false
    t.string "session_token"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "phone_number"
    t.boolean "sms_verification_enabled", default: false
    t.string "sms_verification_code"
    t.datetime "sms_code_expires_at"
    t.datetime "phone_verified_at"
    t.index ["active"], name: "index_users_on_active"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["failed_attempts"], name: "index_users_on_failed_attempts"
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
    t.index ["role"], name: "index_users_on_role"
    t.index ["session_token"], name: "index_users_on_session_token"
    t.index ["unlock_token"], name: "index_users_on_unlock_token"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "sale_items", "products"
  add_foreign_key "sale_items", "sales"
  add_foreign_key "sales", "customers"
  add_foreign_key "sales", "users"
end
