class CreateAuditEvents < ActiveRecord::Migration
  
  def self.up
    create_table :audit_events do |t|
      t.datetime :created_at, :null => false
      t.integer :who_id
      t.string :from
      t.string :name, :null => false
      t.string :target_type
      t.integer :target_id
      t.string :encoded_info
    end
  end

  def self.down
    drop_table :audit_events
  end
  
end
