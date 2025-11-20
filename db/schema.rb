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

ActiveRecord::Schema[8.1].define(version: 2025_11_19_161806) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "forecasts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "forecast_horizon_months", null: false
    t.datetime "generated_at", null: false
    t.jsonb "predicted_monthly_net_savings", default: []
    t.decimal "starting_balance", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["generated_at"], name: "index_forecasts_on_generated_at"
    t.index ["user_id"], name: "index_forecasts_on_user_id"
  end

  create_table "scenarios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "expense_reduction_percent", precision: 5, scale: 2, default: "0.0"
    t.decimal "extra_monthly_savings", precision: 10, scale: 2, default: "0.0"
    t.bigint "forecast_id", null: false
    t.string "name"
    t.jsonb "resulting_predicted_net_savings", default: []
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_scenarios_on_created_at"
    t.index ["forecast_id"], name: "index_scenarios_on_forecast_id"
    t.index ["user_id"], name: "index_scenarios_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "description", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category"], name: "index_transactions_on_category"
    t.index ["date"], name: "index_transactions_on_date"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.decimal "monthly_income", precision: 10, scale: 2
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.decimal "savings_goal_amount", precision: 10, scale: 2
    t.integer "savings_goal_months"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "forecasts", "users"
  add_foreign_key "scenarios", "forecasts"
  add_foreign_key "scenarios", "users"
  add_foreign_key "transactions", "users"
end
