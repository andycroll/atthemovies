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

ActiveRecord::Schema[8.1].define(version: 2026_10_07_152302) do
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

  create_table "cinemas", force: :cascade do |t|
    t.string "public_id", null: false
    t.string "name", null: false
    t.string "brand", null: false
    t.string "street_address"
    t.string "extended_address"
    t.string "locality"
    t.string "region"
    t.string "postal_code"
    t.string "country"
    t.string "country_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "screenings_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_cinemas_on_public_id", unique: true
  end

  create_table "external_identifiers", force: :cascade do |t|
    t.string "identifiable_type", null: false
    t.integer "identifiable_id", null: false
    t.string "source", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifiable_type", "identifiable_id"], name: "index_external_identifiers_on_identifiable"
    t.index ["source", "value"], name: "index_external_identifiers_on_source_and_value", unique: true
  end

  create_table "film_aliases", force: :cascade do |t|
    t.integer "film_id", null: false
    t.string "name", null: false
    t.string "normalized_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["film_id"], name: "index_film_aliases_on_film_id"
    t.index ["normalized_name"], name: "index_film_aliases_on_normalized_name", unique: true
  end

  create_table "films", force: :cascade do |t|
    t.string "public_id", null: false
    t.string "name", null: false
    t.integer "year"
    t.integer "runtime"
    t.string "tagline"
    t.text "overview"
    t.string "enrichment_state", default: "pending", null: false
    t.boolean "event", default: false, null: false
    t.boolean "hidden", default: false, null: false
    t.integer "performances_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "poster_source_url"
    t.string "backdrop_source_url"
    t.index ["public_id"], name: "index_films_on_public_id", unique: true
  end

  create_table "performances", force: :cascade do |t|
    t.integer "cinema_id", null: false
    t.integer "film_id", null: false
    t.string "dimension", default: "2d", null: false
    t.string "variant", default: "standard", null: false
    t.datetime "starting_at", null: false
    t.string "booking_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cinema_id", "film_id", "dimension", "starting_at"], name: "performance_import_identity", unique: true
    t.index ["cinema_id"], name: "index_performances_on_cinema_id"
    t.index ["film_id"], name: "index_performances_on_film_id"
    t.index ["starting_at"], name: "index_performances_on_starting_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tmdb_candidates", force: :cascade do |t|
    t.integer "film_id", null: false
    t.string "tmdb_id", null: false
    t.string "name", null: false
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["film_id", "tmdb_id"], name: "index_tmdb_candidates_on_film_id_and_tmdb_id", unique: true
    t.index ["film_id"], name: "index_tmdb_candidates_on_film_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "film_aliases", "films"
  add_foreign_key "performances", "cinemas"
  add_foreign_key "performances", "films"
  add_foreign_key "sessions", "users"
  add_foreign_key "tmdb_candidates", "films"
end
