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

ActiveRecord::Schema[8.0].define(version: 2025_02_20_004428) do
  create_table "gaggle_channels_gooses", id: false, force: :cascade do |t|
    t.integer "channel_id", null: false
    t.integer "goose_id", null: false
    t.index [ "channel_id", "goose_id" ], name: "index_gaggle_channels_gooses_on_channel_id_and_goose_id"
    t.index [ "goose_id", "channel_id" ], name: "index_gaggle_channels_gooses_on_goose_id_and_channel_id"
  end

  create_table "gaggle_gooses", force: :cascade do |t|
    t.string "name", null: false
    t.text "prompt"
    t.string "process_pid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gaggle_message_reads", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "message_id", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "message_id" ], name: "index_gaggle_message_reads_on_message_id"
    t.index [ "user_id" ], name: "index_gaggle_message_reads_on_user_id"
  end

  create_table "gaggle_messages", force: :cascade do |t|
    t.text "content", null: false
    t.integer "gaggle_thread_id", null: false
    t.integer "gaggle_goose_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "gaggle_goose_id" ], name: "index_gaggle_messages_on_gaggle_goose_id"
    t.index [ "gaggle_thread_id" ], name: "index_gaggle_messages_on_gaggle_thread_id"
  end

  create_table "gaggle_notifications", force: :cascade do |t|
    t.integer "gaggle_message_id", null: false
    t.integer "gaggle_goose_id"
    t.datetime "read_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "delivered_at"
    t.index [ "gaggle_goose_id" ], name: "index_gaggle_notifications_on_gaggle_goose_id"
    t.index [ "gaggle_message_id" ], name: "index_gaggle_notifications_on_gaggle_message_id"
  end

  create_table "gaggle_sessions", force: :cascade do |t|
    t.integer "goose_id", null: false
    t.string "log_file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "goose_id" ], name: "index_gaggle_sessions_on_goose_id"
  end

  create_table "gaggle_threads", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "gaggle_message_reads", "messages"
  add_foreign_key "gaggle_message_reads", "users"
  add_foreign_key "gaggle_messages", "gaggle_gooses"
  add_foreign_key "gaggle_messages", "gaggle_threads"
  add_foreign_key "gaggle_notifications", "gaggle_gooses"
  add_foreign_key "gaggle_notifications", "gaggle_messages"
  add_foreign_key "gaggle_sessions", "gaggle_gooses", column: "goose_id"
end
