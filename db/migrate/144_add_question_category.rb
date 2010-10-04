class AddQuestionCategory < ActiveRecord::Migration
  def self.up
    add_column :questions, :category, :string, :limit => 40
    add_index :questions, :category
  end

  def self.down
    remove_index :questions, :category
    remove_column :questions, :category
  end
end
