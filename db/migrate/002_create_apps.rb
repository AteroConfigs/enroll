class CreateApps < ActiveRecord::Migration
  def self.up
    create_table :apps do |t|
      t.string :first_name
      t.string :last_name
      t.text :notes
      t.integer :priority_type

      t.timestamps
    end
  end

  def self.down
    drop_table :apps
  end
end
