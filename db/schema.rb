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

ActiveRecord::Schema[8.1].define(version: 2026_10_28_000005) do
  create_table "course_sessions", force: :cascade do |t|
    t.integer "course_id", null: false
    t.string "title", null: false
    t.integer "position", default: 0, null: false
    t.string "vdocipher_video_id", null: false
    t.integer "duration"
    t.string "status", default: "processing", null: false
    t.boolean "preview", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "position"], name: "index_course_sessions_on_course_id_and_position"
    t.index ["course_id"], name: "index_course_sessions_on_course_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "session_progresses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_session_id", null: false
    t.integer "watched_seconds", default: 0, null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_session_id"], name: "index_session_progresses_on_course_session_id"
    t.index ["user_id", "course_session_id"], name: "index_session_progresses_on_user_id_and_course_session_id", unique: true
    t.index ["user_id"], name: "index_session_progresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "course_sessions", "courses"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "session_progresses", "course_sessions"
  add_foreign_key "session_progresses", "users"
end
