class AddActiveToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :active, :integer, :default => 1
  end

  def self.down
    remoce_column :questions, :active
  end
end
