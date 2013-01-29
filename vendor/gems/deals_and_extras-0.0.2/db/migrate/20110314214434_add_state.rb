class AddState < ActiveRecord::Migration
  def self.up
    create_table :states do |t|
      t.timestamps
      t.string :abbreviation
      t.string :state
    end
  end

  def self.down
  end
end
