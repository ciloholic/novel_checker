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

ActiveRecord::Schema[8.0].define(version: 2022_03_26_155802) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "chapters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "novel_id"
    t.integer "chapter", default: 0, null: false
    t.string "sub_title"
    t.text "content"
    t.datetime "post_at"
    t.datetime "edit_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["novel_id"], name: "index_chapters_on_novel_id"
  end

  create_table "novels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "site_id"
    t.string "code", null: false
    t.string "title"
    t.boolean "non_target", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "code"], name: "index_novels_on_site_id_and_code", unique: true
    t.index ["site_id"], name: "index_novels_on_site_id"
  end

  create_table "scraping_statuses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "site_id"
    t.datetime "executing_time"
    t.index ["site_id"], name: "index_scraping_statuses_on_site_id"
  end

  create_table "sites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "url", null: false
    t.bigint "sort", null: false
    t.boolean "restrict", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_sites_on_code", unique: true
  end

  add_foreign_key "chapters", "novels"
  add_foreign_key "novels", "sites"
  add_foreign_key "scraping_statuses", "sites"
end
