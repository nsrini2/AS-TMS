class ConvertAdminsToSysAdmins < ActiveRecord::Migration
  def self.up
    Profile.find(:all, :conditions => { :is_admin => true }).each do |admin|
      admin.add_roles(Role::ReportAdmin, Role::ContentAdmin, Role::ShadyAdmin, Role::UserAdmin, Role::AwardsAdmin)
      admin.save
    end
    
    remove_column :profiles, :is_admin
  end

  def self.down
    add_column :profiles, :is_admin, :boolean, :default => false, :null => false
  end
end
