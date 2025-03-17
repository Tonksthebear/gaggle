ActiveRecord::Schema[7.2].define(version: 1) do
  create_table "gaggle_channels", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "gaggle_channels_gooses", id: false, force: :cascade do |t|
    t.integer "channel_id", null: false
    t.integer "goose_id", null: false
    t.index [ "channel_id", "goose_id" ], name: "index_gaggle_channels_gooses_on_channel_id_and_goose_id"
    t.index [ "goose_id", "channel_id" ], name: "index_gaggle_channels_gooses_on_goose_id_and_channel_id"
  end

  create_table "gaggle_gooses", force: :cascade do |t|
    t.string "name", null: false
    t.text "prompt"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "gaggle_messages", force: :cascade do |t|
    t.text "content", null: false
    t.integer "goose_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "messageable_type", null: false
    t.integer "messageable_id", null: false
    t.index [ "goose_id" ], name: "index_gaggle_messages_on_goose_id"
    t.index [ "messageable_type", "messageable_id" ], name: "index_gaggle_messages_on_messageable"
  end

  create_table "gaggle_notifications", force: :cascade do |t|
    t.integer "message_id"
    t.integer "goose_id"
    t.datetime "read_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "messageable_type", null: false
    t.integer "messageable_id", null: false
    t.datetime "delivered_at"
    t.index [ "goose_id" ], name: "index_gaggle_notifications_on_goose_id"
    t.index [ "message_id" ], name: "index_gaggle_notifications_on_message_id"
    t.index [ "messageable_type", "messageable_id" ], name: "idx_on_messageable_type_messageable_id_e697f3e48f"
  end

  create_table "gaggle_sessions", force: :cascade do |t|
    t.integer "goose_id", null: false
    t.string "log_file"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index [ "goose_id" ], name: "index_gaggle_sessions_on_goose_id"
  end

  add_foreign_key "gaggle_messages", "gaggle_gooses", column: "goose_id"
  add_foreign_key "gaggle_notifications", "gaggle_gooses", column: "goose_id"
  add_foreign_key "gaggle_notifications", "gaggle_messages", column: "message_id"
  add_foreign_key "gaggle_sessions", "gaggle_gooses", column: "goose_id"
end
