class CreateCompanyStreamEvents < ActiveRecord::Migration
  def self.up
    create_table :company_stream_events do |t|
      t.column :klass, :string
      t.column :klass_id, :integer
      t.column :profile_id, :integer
      t.column :action, :string
      t.column :company_id, :integer
      t.column :group_id, :integer
      
      t.timestamps
    end  
      add_index :company_stream_events, :created_at
      add_index :company_stream_events, :company_id
  end

  def self.down
    drop_table :company_stream_events
  end
end
