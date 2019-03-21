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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2016_02_11_220033) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "cinemas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.decimal "latitude", precision: 9, scale: 6
    t.decimal "longitude", precision: 9, scale: 6
    t.string "street_address"
    t.string "extended_address"
    t.string "locality"
    t.string "postal_code"
    t.string "region"
    t.string "country"
    t.string "country_code", limit: 3
    t.string "brand"
    t.string "brand_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "screenings_url"
    t.string "information_url"
    t.index ["latitude", "longitude"], name: "index_cinemas_on_latitude_and_longitude"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "films", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "overview"
    t.string "year", limit: 4
    t.integer "runtime"
    t.text "tagline"
    t.text "poster"
    t.text "backdrop"
    t.integer "tmdb_identifier"
    t.string "tmdb_possibles", default: [], array: true
    t.text "backdrop_source_uri"
    t.text "poster_source_uri"
    t.string "imdb_identifier"
    t.string "url"
    t.text "alternate_names", default: [], array: true
    t.boolean "information_added", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "event", default: false
    t.boolean "hidden", default: false
    t.text "name_hashes", default: [], array: true
    t.integer "performances_count"
    t.index ["name"], name: "index_films_on_name"
  end

  create_table "performances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "film_id", null: false
    t.uuid "cinema_id", null: false
    t.string "dimension", null: false
    t.string "variant", null: false
    t.datetime "starting_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cinema_id"], name: "index_performances_on_cinema_id"
  end

end
