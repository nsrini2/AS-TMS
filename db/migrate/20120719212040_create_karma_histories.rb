class CreateKarmaHistories < ActiveRecord::Migration
  def self.up
    create_table :karma_histories do |t|
      t.integer :profile_id
      t.integer :month
      t.integer :year
      t.integer :value    
    end
  end
  
  def self.down
    drop_table :karma_histories
  end
end
