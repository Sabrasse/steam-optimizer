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

ActiveRecord::Schema[7.1].define(version: 2025_06_01_114910) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analyses", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.jsonb "tags_list", default: {}
    t.jsonb "ai_suggestions", default: {}
    t.text "image_suggestions"
    t.text "image_validation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_rating_tags"
    t.string "user_rating_image"
    t.string "user_rating_description"
    t.text "user_feedback_tags"
    t.text "user_feedback_image"
    t.text "user_feedback_description"
    t.index ["game_id", "created_at"], name: "index_analyses_on_game_id_and_created_at"
    t.index ["game_id"], name: "index_analyses_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "steam_app_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.text "short_description"
    t.text "about_the_game"
    t.string "capsule_image_url"
    t.jsonb "genres", default: {}
    t.jsonb "categories", default: {}
    t.jsonb "screenshots", default: {}
    t.jsonb "movies", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_games_on_slug", unique: true
    t.index ["steam_app_id"], name: "index_games_on_steam_app_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "analyses", "games"
end
