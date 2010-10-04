class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |table|
      table.string    :body
      table.integer   :profile_id
      
      table.datetime  :created_at
      
      # There is no updated_at by design. Not needed
    end
    
    add_index :statuses, :profile_id
  end

  def self.down
    drop_table :statuses  
  end
end
