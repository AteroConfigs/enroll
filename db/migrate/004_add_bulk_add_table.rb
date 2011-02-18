class AddBulkAddTable < ActiveRecord::Migration
  def self.up
    create_table "bulks", :force => true do |t|
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
      t.string   "siblings"
      t.date     "birthdate"
    end

  end

  def self.down
    drop_table "bulks"
  end
end

