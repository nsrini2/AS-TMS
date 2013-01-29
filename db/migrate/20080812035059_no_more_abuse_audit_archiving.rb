class NoMoreAbuseAuditArchiving < ActiveRecord::Migration
  
  def self.up
    add_column :abuses, :remover_id, :int, :null => true
    add_column :abuses, :removed_at, :datetime, :null => true
    # drop uniqueness
    remove_index :abuses, [:abuseable_type, :abuseable_id]
    add_index :abuses, [:abuseable_type, :abuseable_id]
    Abuse.find_from_audits(:deleted_items => true).each do |abuse|
      new_abuse = abuse.clone
      new_abuse.remover_id = abuse.audit_deleted_by_id
      new_abuse.removed_at = abuse.audit_deleted_at
      new_abuse.save!
    end    
  end

  def self.down
    execute 'delete from abuses where remover_id is not null'
    remove_column :abuses, :removed_at
    remove_column :abuses, :remover_id
    remove_index :abuses, [:abuseable_type, :abuseable_id]
    add_index :abuses, [:abuseable_type, :abuseable_id], :unique => true
  end
end
