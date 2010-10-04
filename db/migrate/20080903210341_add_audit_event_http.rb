class AddAuditEventHttp < ActiveRecord::Migration
  
  def self.up
    drop_table :audit_events
    create_table :audit_events, :options => "ENGINE=MyISAM" do |t|
      t.datetime :created_at, :null => false
      t.integer :who_id
      t.string :name, :null => false
      t.string :action
      t.text :info
      t.text :trace
      t.string :target_type
      t.integer :target_id
    end
  end

  def self.down
    # no need
  end
  
end
