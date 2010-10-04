class CreateAwardsTable < ActiveRecord::Migration
  def self.up
    create_table :awards do |t|
      t.text :title
      t.boolean :visible, :default => 1
    end
  end

  def self.down
    drop_table :awards
  end
end