class CreateTempUsers < ActiveRecord::Migration
  def self.up
    create_table :temp_users do |t|
      t.string :email
      t.string :name
      t.string :pcc

      t.timestamps
    end
  end

  def self.down
    drop_table :temp_users
  end
end
