class AddCompanyIdToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :company_id, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :questions, :company_id
  end
end
