class CreateUser < ActiveRecord::Migration
  def self.up
    
    create_table :users do |t|
      t.timestamps
      
      t.string :login
      t.string :password
      t.string :email
    end
    
  end

  def self.down
  end
end
