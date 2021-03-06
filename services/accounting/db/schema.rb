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

ActiveRecord::Schema[7.0].define(version: 2022_05_20_021015) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_permissions_on_name", unique: true
  end

  create_table "permissions_roles", id: false, force: :cascade do |t|
    t.uuid "permission_id", null: false
    t.uuid "role_id", null: false
    t.index ["permission_id"], name: "index_permissions_roles_on_permission_id"
    t.index ["role_id"], name: "index_permissions_roles_on_role_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.uuid "role_id", null: false
    t.uuid "user_id", null: false
    t.index ["role_id"], name: "index_roles_users_on_role_id"
    t.index ["user_id"], name: "index_roles_users_on_user_id"
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "task_idx", null: false
    t.string "description", null: false
    t.uuid "user_id"
    t.integer "status", default: 0
    t.datetime "completed_at", precision: nil
    t.float "cost"
    t.float "reward"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jira_id"
    t.index ["task_idx"], name: "index_tasks_on_task_idx", unique: true
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "transaction_log_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.datetime "event_time", precision: nil, null: false
    t.datetime "record_time", precision: nil, null: false
    t.float "amount", null: false
    t.integer "record_type", null: false
    t.uuid "reference_id"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_time"], name: "index_transaction_log_records_on_record_time", using: :brin
    t.index ["record_type"], name: "index_transaction_log_records_on_record_type"
    t.index ["user_id"], name: "index_transaction_log_records_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_idx", null: false
    t.string "name"
    t.string "email"
    t.integer "status", default: 1
    t.float "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_idx"], name: "index_users_on_user_idx", unique: true
  end

end
