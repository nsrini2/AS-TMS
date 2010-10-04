class IncreaseKnowledgeSize < ActiveRecord::Migration
  def self.up
    change_column :profiles, :knowledge, :text
  end

  def self.down
    change_column :profiles, :knowledge, :string
  end
end