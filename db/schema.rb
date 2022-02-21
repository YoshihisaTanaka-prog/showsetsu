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

ActiveRecord::Schema.define(version: 2022_02_18_052123) do

  create_table "chapter_characters", force: :cascade do |t|
    t.integer "chapter_id", null: false
    t.integer "character_id", null: false
    t.integer "order"
    t.boolean "is_effective"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chapter_id"], name: "index_chapter_characters_on_chapter_id"
    t.index ["character_id"], name: "index_chapter_characters_on_character_id"
  end

  create_table "chapter_synopses", force: :cascade do |t|
    t.integer "chapter_id", null: false
    t.integer "synopses_id", null: false
    t.integer "order"
    t.boolean "is_effective"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["chapter_id"], name: "index_chapter_synopses_on_chapter_id"
    t.index ["synopses_id"], name: "index_chapter_synopses_on_synopses_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.string "title"
    t.integer "user_id"
    t.integer "title_id"
    t.integer "order"
    t.integer "first_story_num"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.text "comment"
    t.integer "user_id"
    t.integer "title_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "kept_sessions", force: :cascade do |t|
    t.integer "st_id"
    t.boolean "is_enabled", default: true, null: false
    t.integer "step", default: -1, null: false
    t.integer "title"
    t.integer "chapter"
    t.integer "story"
    t.integer "character"
    t.integer "synopsis"
    t.integer "mode", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "session_tokens", force: :cascade do |t|
    t.string "session_id"
    t.integer "user_id"
    t.boolean "is_enabled", default: true, null: false
    t.string "token"
    t.integer "current_ks_id"
    t.integer "design"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "steps", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "stories", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "user_id"
    t.integer "chapter_id"
    t.integer "order"
    t.integer "step_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "synopses", force: :cascade do |t|
    t.text "comment"
    t.integer "user_id"
    t.integer "title_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "titles", force: :cascade do |t|
    t.string "title"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chapter_characters", "chapters"
  add_foreign_key "chapter_characters", "characters"
  add_foreign_key "chapter_synopses", "chapters"
  add_foreign_key "chapter_synopses", "synopses", column: "synopses_id"
end
