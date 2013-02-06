class AddSurverysTakenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :take_survey, :boolean, :default => false
  end

  def self.down
    remove_column :users, :take_survey
  end
end
