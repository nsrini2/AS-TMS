class AddCompanyIdToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :company_id, :integer
  end

  def self.down
    remove_column :profiles, :company_id
  end
end
