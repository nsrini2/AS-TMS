class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.timestamps
      t.string :name
      t.string :setting
    end
  end

  def self.down
  end
end
