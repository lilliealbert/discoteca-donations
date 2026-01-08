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

ActiveRecord::Schema[8.1].define(version: 2026_01_07_235524) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "donation_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "donor_id", null: false
    t.bigint "event_id", null: false
    t.text "notes"
    t.string "request_status", default: "unasked"
    t.datetime "updated_at", null: false
    t.bigint "volunteer_id"
    t.index ["donor_id"], name: "index_donation_requests_on_donor_id"
    t.index ["event_id"], name: "index_donation_requests_on_event_id"
    t.index ["volunteer_id"], name: "index_donation_requests_on_volunteer_id"
  end

  create_table "donations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "donation_request_id"
    t.string "donation_type"
    t.bigint "donor_id", null: false
    t.bigint "event_id", null: false
    t.text "fine_print"
    t.boolean "in_hand"
    t.text "notes"
    t.text "short_description"
    t.datetime "updated_at", null: false
    t.bigint "volunteer_id", null: false
    t.index ["donation_request_id"], name: "index_donations_on_donation_request_id"
    t.index ["donor_id"], name: "index_donations_on_donor_id"
    t.index ["event_id"], name: "index_donations_on_event_id"
    t.index ["volunteer_id"], name: "index_donations_on_volunteer_id"
  end

  create_table "donors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address"
    t.string "name"
    t.text "notes"
    t.string "phone_number"
    t.string "primary_contact"
    t.string "relationship_to_teca"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "volunteers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_volunteers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_volunteers_on_reset_password_token", unique: true
  end

  add_foreign_key "donation_requests", "donors"
  add_foreign_key "donation_requests", "events"
  add_foreign_key "donation_requests", "volunteers"
  add_foreign_key "donations", "donation_requests"
  add_foreign_key "donations", "donors"
  add_foreign_key "donations", "events"
  add_foreign_key "donations", "volunteers"
end
