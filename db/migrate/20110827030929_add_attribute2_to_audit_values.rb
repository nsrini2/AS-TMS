class AddAttribute2ToAuditValues < ActiveRecord::Migration
  def self.up
    rename_column :audit_values, :attribute, :attribute_name
  end

  def self.down
    rename_column :audit_values, :attribute_name, :attribute
  end
end
