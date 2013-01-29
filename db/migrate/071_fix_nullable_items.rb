class FixNullableItems < ActiveRecord::Migration

  def self.up

    # 039,051
    [:profile_views,:karma_points,:karma_login_points,:karma_timeout].each do |s|
      Profile.update_all "#{s}=0","#{s} is null"
      change_column :profiles, s, :integer, :default => 0, :null => false
    end
    Profile.update_all "completed_once=0","completed_once is null"
    change_column :profiles, :completed_once, :boolean, :default => false, :null => false

    Profile.update_all "is_admin=0","is_admin is null"
    change_column :profiles, :is_admin, :boolean, :default => false, :null => false

    # 063
    #change_column :audits, :created_at, :datetime, :null => false # (tries to set default null)
    execute 'ALTER TABLE audits MODIFY COLUMN created_at DATETIME NOT NULL'
    change_column :audits, :auditable_type, :string, :null => false
    #change_column :audits, :auditable_id, :integer, :null => false # (tries to set default null)
    execute 'ALTER TABLE audits MODIFY COLUMN auditable_id int(11) NOT NULL'
    change_column :audits, :action, :string, :null => false
    #change_column :audit_values, :audit_id, :integer, :null => false # (tries to set default null)
    execute 'ALTER TABLE audit_values MODIFY COLUMN audit_id int(11) NOT NULL'

    # 069
    QuestionReferral.update_all "active=1","active is null"
    change_column :question_referrals, :active, :boolean, :null => false, :default => true

  end

  def self.down
  end

end
