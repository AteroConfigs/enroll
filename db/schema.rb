# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 3) do

  create_table "apps", :force => true do |t|
    t.string   "first_name",         :limit => 50
    t.string   "last_name",          :limit => 50
    t.date     "application_date"
    t.date     "orientation_date"
    t.date     "tour_date"
    t.string   "code",               :limit => 50
    t.integer  "grade"
    t.integer  "grade_in_year"
    t.integer  "status"
    t.integer  "priority_type"
    t.integer  "sequence_number"
    t.integer  "wait_list_position"
    t.string   "street_1",           :limit => 50
    t.string   "street_2",           :limit => 50
    t.string   "city",               :limit => 50
    t.string   "state",              :limit => 50
    t.string   "zip",                :limit => 50
    t.string   "father_first_name",  :limit => 50
    t.string   "father_last_name",   :limit => 50
    t.string   "father_phone_cell",  :limit => 50
    t.string   "father_phone_home",  :limit => 50
    t.string   "father_phone_work",  :limit => 50
    t.string   "father_email_home",  :limit => 50
    t.string   "father_email_work",  :limit => 50
    t.string   "father_street_1",    :limit => 50
    t.string   "father_street_2",    :limit => 50
    t.string   "father_city",        :limit => 50
    t.string   "father_state",       :limit => 50
    t.string   "father_zip",         :limit => 50
    t.string   "mother_first_name",  :limit => 50
    t.string   "mother_last_name",   :limit => 50
    t.string   "mother_phone_cell",  :limit => 50
    t.string   "mother_phone_home",  :limit => 50
    t.string   "mother_phone_work",  :limit => 50
    t.string   "mother_email_home",  :limit => 50
    t.string   "mother_email_work",  :limit => 50
    t.string   "mother_street_1",    :limit => 50
    t.string   "mother_street_2",    :limit => 50
    t.string   "mother_city",        :limit => 50
    t.string   "mother_state",       :limit => 50
    t.string   "mother_zip",         :limit => 50
    t.text     "notes"
    t.datetime "last_update"
    t.string   "siblings"
    t.datetime "updated_at"
    t.date     "birthdate"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

end
