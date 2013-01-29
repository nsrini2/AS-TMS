class CreateAudits < ActiveRecord::Migration

  def self.up

    create_table :audits, :options => "ENGINE=MyISAM" do |t|
      t.column :created_at, :datetime, :null => false
      t.column :auditable_type, :string, :null => false
      t.column :auditable_id, :integer, :null => false
      t.column :action, :string, :null => false
      t.column :who_id, :integer
    end
    add_index :audits, :created_at
    add_index :audits, [:auditable_type, :auditable_id]
    add_index :audits, :action
    add_index :audits, :who_id

    create_table :audit_values, :options => "ENGINE=MyISAM" do |t|
      t.column :audit_id, :integer, :null => false
      t.column :attribute, :string
      t.column :value, :text
    end
    add_index :audit_values, :audit_id
    add_index :audit_values, :attribute

  end

  def self.down
    drop_table :audit_values
    drop_table :audits
  end

end
