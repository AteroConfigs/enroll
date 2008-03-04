class ChangeDateColumns < ActiveRecord::Migration
  def self.up
    change_column :apps, :application_date, :date
    change_column :apps, :orientation_date, :date
    change_column :apps, :tour_date, :date

  end

  def self.down
    change_column :apps, :application_date, :datetime
    change_column :apps, :orientation_date, :datetime
    change_column :apps, :tour_date, :datetime
  end
end
