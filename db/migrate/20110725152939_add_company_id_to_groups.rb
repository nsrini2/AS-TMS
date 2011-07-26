class AddCompanyIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :company_id, :integer, :default => 0
  end

  def self.down
    remove_column :groups, :company_id
  end
end
