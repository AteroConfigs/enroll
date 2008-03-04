class AddFields < ActiveRecord::Migration
  def self.up
    add_column :apps, :siblings, :string
    add_column :apps, :updated_at, :datetime
    add_column :apps, :birthdate, :date
    remove_column :apps, :type
  end

  def self.down
    remove_column :apps, :siblings
    remove_column :apps, :updated_at
    remove_column :apps, :birthdate
    add_column :apps, :type, :string
  end
end
