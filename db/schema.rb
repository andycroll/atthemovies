# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141102212443) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cinemas", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.decimal  "latitude",                   precision: 9, scale: 6
    t.decimal  "longitude",                  precision: 9, scale: 6
    t.string   "street_address"
    t.string   "extended_address"
    t.string   "locality"
    t.string   "postal_code"
    t.string   "region"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country"
    t.string   "country_code",     limit: 3
    t.string   "brand"
    t.string   "brand_identifier"
  end

  add_index "cinemas", ["latitude", "longitude"], name: "index_cinemas_on_latitude_and_longitude", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "films", force: true do |t|
    t.string   "name",                             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tmdb_identifier"
    t.string   "tmdb_possibles",      default: [],              array: true
    t.text     "backdrop_source_uri"
    t.text     "poster_source_uri"
    t.string   "imdb_identifier"
    t.text     "overview"
    t.integer  "runtime"
    t.text     "tagline"
    t.text     "poster"
    t.text     "backdrop"
    t.string   "url"
    t.integer  "screenings_count"
    t.text     "alternate_names",     default: [],              array: true
  end

  create_table "screenings", force: true do |t|
    t.integer  "film_id",    null: false
    t.integer  "cinema_id",  null: false
    t.string   "variant",    null: false
    t.datetime "showing_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dimension"
  end

  add_index "screenings", ["cinema_id"], name: "index_screenings_on_cinema_id", using: :btree

end
